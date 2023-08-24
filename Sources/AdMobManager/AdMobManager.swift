//
//  AdMobManager.swift
//  AdMobManager
//
//  Created by Trịnh Xuân Minh on 25/03/2022.
//

import Foundation
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
    case appOpen
    case interstitial
    case rewarded
    case rewardedInterstitial
  }
  
  public enum AdType {
    case onceUsed(type: OnceUsed)
    case reuse(type: Reuse)
  }
  
  private let remoteConfig = RemoteConfig.remoteConfig()
  private var loadRemoteConfigState: Bool? = false
  private var subscriptions = [AnyCancellable]()
  private var adMobConfig: AdMobConfig?
  private var listAds: [String: AdProtocol] = [:]
  private var registerCompletedHandler: Handler?
  
  public func register(remoteKey: String, completed: Handler?) {
    self.registerCompletedHandler = completed
    NetworkAdMob.shared.$isConnected.sink { [weak self] isConnected in
      guard let self = self else {
        return
      }
      if isConnected, self.loadRemoteConfigState == false {
        self.fetchRemoteConfig(remoteKey)
      }
    }.store(in: &subscriptions)
  }
  
  public func isRegisterSuccessfully() -> Bool {
    return loadRemoteConfigState == true
  }
  
  public func status(type: AdType, name: String) -> Bool? {
    guard let adMobConfig = adMobConfig else {
      print("AdMobManager: Not yet registered!")
      return nil
    }
    guard adMobConfig.status else {
      return false
    }
    switch type {
    case .onceUsed(let type):
      switch type {
      case .native:
        for native in adMobConfig.natives where native.name == name {
          return native.status
        }
      case .banner:
        for banner in adMobConfig.banners where banner.name == name {
          return banner.status
        }
      }
    case .reuse(let type):
      switch type {
      case .appOpen:
        for appOpen in adMobConfig.appOpens where appOpen.name == name {
          return appOpen.status
        }
      case .interstitial:
        for interstitial in adMobConfig.interstitials where interstitial.name == name {
          return interstitial.status
        }
      case .rewarded:
        for rewarded in adMobConfig.rewardeds where rewarded.name == name {
          return rewarded.status
        }
      case .rewardedInterstitial:
        for rewardedInterstitial in adMobConfig.rewardedInterstitials where rewardedInterstitial.name == name {
          return rewardedInterstitial.status
        }
      }
    }
    print("AdMobManager: Ads don't exist!")
    return nil
  }
  
  public func load(type: Reuse, name: String) {
    guard status(type: .reuse(type: type), name: name) == true else {
      print("AdMobManager: Ads are not allowed to show!")
      return
    }
    guard let adMobConfig = adMobConfig else {
      return
    }
    guard listAds[name] == nil else {
      print("AdMobManager: Ads are working!")
      return
    }
    let ad: AdProtocol!
    switch type {
    case .appOpen:
      guard let appOpen = adMobConfig.appOpens.first(where: { $0.name == name }) else {
        return
      }
      ad = AppOpenAd()
      ad.config(ad: appOpen)
    case .interstitial:
      guard let interstitial = adMobConfig.interstitials.first(where: { $0.name == name }) else {
        return
      }
      ad = InterstitialAd()
      ad.config(ad: interstitial)
    case .rewarded:
      guard let rewarded = adMobConfig.rewardeds.first(where: { $0.name == name }) else {
        return
      }
      ad = RewardedAd()
      ad.config(ad: rewarded)
    case .rewardedInterstitial:
      guard let rewardedInterstitial = adMobConfig.rewardedInterstitials.first(where: { $0.name == name }) else {
        return
      }
      ad = RewardedInterstitialAd()
      ad.config(ad: rewardedInterstitial)
    }
    self.listAds[name] = ad
  }

  public func isReady(name: String) -> Bool? {
    guard let ad = listAds[name] else {
      print("Ads do not exist!")
      return nil
    }
    return ad.isReady()
  }

  public func show(
    name: String,
    willPresent: Handler? = nil,
    willDismiss: Handler? = nil,
    didDismiss: Handler? = nil,
    didFail: Handler? = nil
  ) {
    guard let ad = listAds[name] else {
      print("Ads do not exist!")
      return
    }
    guard !checkIsPresent() else {
      print("Ads display failure - other ads is showing!")
      return
    }
    ad.show(
      willPresent: willPresent,
      willDismiss: willDismiss,
      didDismiss: didDismiss,
      didFail: didFail)
  }
}

extension AdMobManager {
  func getOnceUsedAd(type: OnceUsed, name: String) -> Any? {
    guard status(type: .onceUsed(type: type), name: name) == true else {
      print("AdMobManager: Ads are not allowed to show!")
      return nil
    }
    guard let adMobConfig = adMobConfig else {
      return nil
    }
    switch type {
    case .native:
      return adMobConfig.natives.first(where: { $0.name == name })
    case .banner:
      return adMobConfig.banners.first(where: { $0.name == name })
    }
  }
}

extension AdMobManager {
  private func checkIsPresent() -> Bool {
    for ad in listAds {
      if ad.value.isPresent() {
        return true
      }
    }
    return false
  }
  
  private func fetchRemoteConfig(_ key: String) {
    self.loadRemoteConfigState = nil
    remoteConfig.fetch(withExpirationDuration: 0) { [weak self] _, error in
      guard let self = self else {
        return
      }
      guard error == nil else {
        self.loadRemoteConfigState = false
        return
      }
      self.remoteConfig.activate()
      self.updateWithRCValues(key)
    }
  }
  
  private func updateWithRCValues(_ key: String) {
    let adMobData = remoteConfig.configValue(forKey: key).dataValue
    guard let adMobConfig = try? JSONDecoder().decode(AdMobConfig.self, from: adMobData) else {
      self.loadRemoteConfigState = false
      return
    }
    self.loadRemoteConfigState = true
    self.adMobConfig = adMobConfig
    registerCompletedHandler?()
  }
}
