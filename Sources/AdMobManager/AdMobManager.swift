//
//  AdMobManager.swift
//  AdMobManager
//
//  Created by Trịnh Xuân Minh on 25/03/2022.
//

import UIKit
import FirebaseRemoteConfig
import GoogleMobileAds
import Combine

/// An ad management structure. It supports setting InterstitialAd, RewardedAd, RewardedInterstitialAd, AppOpenAd, NativeAd, BannerAd.
/// ```
/// import AdMobManager
/// ```
/// - Warning: Available for Swift 5.3, Xcode 12.5 (macOS Big Sur). Support from iOS 13.0 or newer.
public class AdMobManager {
  public static var shared = AdMobManager()
  
  public enum OnceUsed {
    case native
    case banner
  }
  
  public enum Reuse {
    case splash
    case appOpen
    case interstitial
    case rewarded
    case rewardedInterstitial
  }
  
  public enum AdType {
    case onceUsed(_ type: OnceUsed)
    case reuse(_ type: Reuse)
  }
  
  private let remoteConfig = RemoteConfig.remoteConfig()
  private var retryAttempt = 0
  private var subscriptions = [AnyCancellable]()
  private var remoteKey: String?
  private var defaultData: Data?
  private var fetchCompletedHandler: Handler?
  private var adMobConfig: AdMobConfig?
  private var listAds: [String: AdProtocol] = [:]
  
  public func register(remoteKey: String, defaultData: Data, completed: Handler?) {
    guard self.remoteKey == nil else {
      return
    }
    self.remoteKey = remoteKey
    self.defaultData = defaultData
    self.fetchCompletedHandler = completed
    
    fetchCache()
    
    NetworkAdMob.shared.$isConnected.sink { [weak self] isConnected in
      guard let self = self else {
        return
      }
      if isConnected, self.retryAttempt == 0 {
        self.fetchRemote()
      }
    }.store(in: &subscriptions)
  }

  public func status(type: AdType, name: String) -> Bool? {
    guard let adMobConfig = adMobConfig else {
      print("AdMobManager: Not yet registered!")
      return nil
    }
    guard adMobConfig.status else {
      return false
    }
    guard let ad = getAd(type: type, name: name) else {
      print("AdMobManager: Ads don't exist!")
      return nil
    }
    
    switch type {
    case .onceUsed(let type):
      switch type {
      case .native:
        if let native = ad as? Native {
          return native.status
        }
      case .banner:
        if let banner = ad as? Banner {
          return banner.status
        }
      }
    case .reuse(let type):
      switch type {
      case .splash:
        if let splash = ad as? Splash {
          return splash.status
        }
      case .appOpen:
        if let appOpen = ad as? AppOpen {
          return appOpen.status
        }
      case .interstitial:
        if let interstitial = ad as? Interstitial {
          return interstitial.status
        }
      case .rewarded:
        if let rewarded = ad as? Rewarded {
          return rewarded.status
        }
      case .rewardedInterstitial:
        if let rewardedInterstitial = ad as? RewardedInterstitial {
          return rewardedInterstitial.status
        }
      }
    }
    print("AdMobManager: Format conversion error!")
    return nil
  }

  public func load(type: Reuse, name: String) {
    guard adMobConfig != nil else {
      print("AdMobManager: Not yet registered!")
      return
    }
    switch status(type: .reuse(type), name: name) {
    case false:
      print("AdMobManager: Ads are not allowed to show!")
      return
    case true:
      break
    default:
      return
    }
    guard listAds[name] == nil else {
      print("AdMobManager: Ads are working!")
      return
    }
    guard let ad = getAd(type: .reuse(type), name: name) else {
      print("AdMobManager: Ads don't exist!")
      return
    }
    
    let adProtocol: AdProtocol!
    switch type {
    case .splash:
      guard let splash = ad as? Splash else {
        print("AdMobManager: Format conversion error!")
        return
      }
      adProtocol = SplashAd()
      adProtocol.config(ad: splash)
    case .appOpen:
      guard let appOpen = ad as? AppOpen else {
        print("AdMobManager: Format conversion error!")
        return
      }
      adProtocol = AppOpenAd()
      adProtocol.config(ad: appOpen)
    case .interstitial:
      guard let interstitial = ad as? Interstitial else {
        print("AdMobManager: Format conversion error!")
        return
      }
      adProtocol = InterstitialAd()
      adProtocol.config(ad: interstitial)
    case .rewarded:
      guard let rewarded = ad as? Rewarded else {
        print("AdMobManager: Format conversion error!")
        return
      }
      adProtocol = RewardedAd()
      adProtocol.config(ad: rewarded)
    case .rewardedInterstitial:
      guard let rewardedInterstitial = ad as? RewardedInterstitial else {
        print("AdMobManager: Format conversion error!")
        return
      }
      adProtocol = RewardedInterstitialAd()
      adProtocol.config(ad: rewardedInterstitial)
    }
    
    self.listAds[name] = adProtocol
  }

  public func show(name: String,
                   rootViewController: UIViewController,
                   didShow: Handler?,
                   didFail: Handler?
  ) {
    guard let ad = listAds[name] else {
      print("AdMobManager: Ads do not exist!")
      didFail?()
      return
    }
    guard !checkIsPresent() else {
      print("AdMobManager: Ads display failure - other ads is showing!")
      didFail?()
      return
    }
    ad.show(rootViewController: rootViewController,
            didShow: didShow,
            didFail: didFail)
  }
}

extension AdMobManager {
  func getAd(type: AdType, name: String) -> Any? {
    guard let adMobConfig = adMobConfig else {
      return nil
    }
    switch type {
    case .onceUsed(let type):
      switch type {
      case .banner:
        return adMobConfig.banners?.first(where: { $0.name == name })
      case .native:
        return adMobConfig.natives?.first(where: { $0.name == name })
      }
    case .reuse(let type):
      switch type {
      case .splash:
        guard
          let splash = adMobConfig.splash,
          splash.name == name
        else {
          return nil
        }
        return adMobConfig.splash
      case .appOpen:
        guard
          let appOpen = adMobConfig.appOpen,
          appOpen.name == name
        else {
          return nil
        }
        return adMobConfig.appOpen
      case .interstitial:
        return adMobConfig.interstitials?.first(where: { $0.name == name })
      case .rewarded:
        return adMobConfig.rewardeds?.first(where: { $0.name == name })
      case .rewardedInterstitial:
        return adMobConfig.rewardedInterstitials?.first(where: { $0.name == name })
      }
    }
  }
}

extension AdMobManager {
  private func checkIsPresent() -> Bool {
    for ad in listAds where ad.value.isPresent() {
      return true
    }
    return false
  }
  
  private func updateCache() {
    guard let remoteKey = remoteKey else {
      return
    }
    guard let adMobConfig = adMobConfig else {
      return
    }
    guard let data = try? JSONEncoder().encode(adMobConfig) else {
      return
    }
    UserDefaults.standard.set(data, forKey: remoteKey)
  }
  
  private func decoding(adMobData: Data) {
    guard let adMobConfig = try? JSONDecoder().decode(AdMobConfig.self, from: adMobData) else {
      print("AdMobManager: Invalid format!")
      return
    }
    self.adMobConfig = adMobConfig
    updateCache()
    fetchCompletedHandler?()
    self.fetchCompletedHandler = nil
  }
  
  private func fetchCache() {
    guard let remoteKey = remoteKey else {
      return
    }
    guard let cacheData = UserDefaults.standard.data(forKey: remoteKey) else {
      return
    }
    decoding(adMobData: cacheData)
  }
  
  private func fetchDefault() {
    guard let defaultData = defaultData else {
      return
    }
    decoding(adMobData: defaultData)
  }
  
  private func retryFetchRemote() {
    if retryAttempt == 1 {
      logErrorFetchRemote()
      DispatchQueue.main.asyncAfter(deadline: .now() + 10.0, execute: fetchRemote)
    } else if adMobConfig == nil {
      fetchDefault()
    }
  }
  
  private func fetchRemote() {
    self.retryAttempt += 1
    guard retryAttempt <= 2 else {
      return
    }
    guard let remoteKey = remoteKey else {
      return
    }
    remoteConfig.fetch(withExpirationDuration: 0) { [weak self] _, error in
      guard let self = self else {
        return
      }
      guard error == nil else {
        self.retryFetchRemote()
        return
      }
      self.remoteConfig.activate()
      let adMobData = remoteConfig.configValue(forKey: remoteKey).dataValue
      guard !adMobData.isEmpty else {
        self.retryFetchRemote()
        return
      }
      self.decoding(adMobData: adMobData)
    }
  }
  
  private func logErrorFetchRemote() {
    let key = "AdMobManager_First_Open"
    if UserDefaults.standard.bool(forKey: key) {
      LogEventManager.shared.log(event: .remoteConfigLoadFailLaunchApp)
    } else {
      LogEventManager.shared.log(event: .remoteConfigLoadFailFirstOpen)
      UserDefaults.standard.set(true, forKey: key)
    }
  }
}
