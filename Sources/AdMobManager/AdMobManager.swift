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
import UserMessagingPlatform

/// An ad management structure. It supports setting InterstitialAd, RewardedAd, RewardedInterstitialAd, AppOpenAd, NativeAd, BannerAd.
/// ```
/// import AdMobManager
/// ```
/// - Warning: Available for Swift 5.3, Xcode 12.5 (macOS Big Sur). Support from iOS 13.0 or newer.
public class AdMobManager {
  public static var shared = AdMobManager()
  
  public enum State {
    case unknow
    case allow
    case reject
  }
  
  public enum OnceUsed: String {
    case native
    case banner
  }
  
  public enum Reuse: String {
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
  
  @Published public private(set) var state: State = .unknow
  private let remoteConfig = RemoteConfig.remoteConfig()
  private let consentKey = "CMP"
  private let remoteTimeout = 10.0
  private var subscriptions = [AnyCancellable]()
  private var remoteKey: String?
  private var defaultData: Data?
  private var didTimeout = false
  private var didSetup = false
  private var didRequestConsent = false
  private var isDebug = false
  private var testDeviceIdentifiers = [String]()
  private var configValue: ((RemoteConfig) -> Void)?
  private var isPremium = false
  private var adMobConfig: AdMobConfig?
  private var consentConfig: ConsentConfig?
  private var listReuseAd: [String: AdProtocol] = [:]
  private var listNativeAd: [String: NativeAd] = [:]
  
  public func upgradePremium() {
    self.isPremium = true
  }
  
  public func addActionConfigValue(_ handler: @escaping ((RemoteConfig) -> Void)) {
    self.configValue = handler
  }
  
  public func register(remoteKey: String, defaultData: Data) {
    if isPremium {
      print("[AdMobManager] Premium!")
      self.state = .reject
    }
    guard self.remoteKey == nil else {
      return
    }
    print("[AdMobManager] Register!")
    LogEventManager.shared.log(event: .register)
    self.remoteKey = remoteKey
    self.defaultData = defaultData
    
    fetchConsentCache()
    fetchAdMobCache()
    fetchRemote()
  }
  
  public func status(type: AdType, name: String) -> Bool? {
    guard !isPremium else {
      print("[AdMobManager] Premium!")
      return nil
    }
    guard let adMobConfig else {
      print("[AdMobManager] Not yet registered!")
      return nil
    }
    guard adMobConfig.status else {
      return false
    }
    guard state == .allow else {
      print("[AdMobManager] Can't Request Ads!")
      return nil
    }
    guard let adConfig = getAd(type: type, name: name) as? AdConfigProtocol else {
      print("[AdMobManager] Ads don't exist!")
      return nil
    }
    return adConfig.status
  }
  
  public func load(type: Reuse,
                   name: String,
                   success: Handler? = nil,
                   fail: Handler? = nil
  ) {
    switch status(type: .reuse(type), name: name) {
    case false:
      print("[AdMobManager] Ads are not allowed to show!")
      return
    case true:
      break
    default:
      return
    }
    guard let adConfig = getAd(type: .reuse(type), name: name) as? AdConfigProtocol else {
      print("[AdMobManager] Ads don't exist!")
      return
    }
    guard listReuseAd[type.rawValue + adConfig.id] == nil else {
      return
    }
    
    let adProtocol: AdProtocol!
    switch type {
    case .splash:
      guard let splash = adConfig as? Splash else {
        print("[AdMobManager] Format conversion error!")
        return
      }
      let splashAd = SplashAd()
      splashAd.config(timeout: splash.timeout)
      adProtocol = splashAd
    case .appOpen:
      adProtocol = AppOpenAd()
    case .interstitial:
      adProtocol = InterstitialAd()
    case .rewarded:
      adProtocol = RewardedAd()
    case .rewardedInterstitial:
      adProtocol = RewardedInterstitialAd()
    }
    adProtocol.config(didFail: fail, didSuccess: success)
    adProtocol.config(id: adConfig.id)
    self.listReuseAd[type.rawValue + adConfig.id] = adProtocol
  }
  
  public func preloadNative(name: String,
                            success: Handler? = nil,
                            fail: Handler? = nil
  ) {
    switch status(type: .onceUsed(.native), name: name) {
    case false:
      print("[AdMobManager] Ads are not allowed to show!")
      return
    case true:
      break
    default:
      return
    }
    guard let native = getAd(type: .onceUsed(.native), name: name) as? Native else {
      print("[AdMobManager] Ads don't exist!")
      return
    }
    guard native.isPreload == true else {
      print("[AdMobManager] Ads are not preloaded!")
      return
    }
    guard listNativeAd[name] == nil else {
      return
    }
    let nativeAd = NativeAd()
    nativeAd.bind(didReceive: success, didError: fail)
    nativeAd.config(ad: native, rootViewController: nil)
    self.listNativeAd[name] = nativeAd
  }
  
  public func show(type: Reuse,
                   name: String,
                   rootViewController: UIViewController,
                   didFail: Handler?,
                   didEarnReward: Handler? = nil,
                   didHide: Handler?
  ) {
    switch status(type: .reuse(type), name: name) {
    case false:
      print("[AdMobManager] Ads are not allowed to show!")
      didFail?()
      return
    case true:
      break
    default:
      didFail?()
      return
    }
    guard let adConfig = getAd(type: .reuse(type), name: name) as? AdConfigProtocol else {
      print("[AdMobManager] Ads don't exist!")
      didFail?()
      return
    }
    guard let ad = listReuseAd[type.rawValue + adConfig.id] else {
      print("[AdMobManager] Ads do not exist!")
      didFail?()
      return
    }
    guard !checkIsPresent() else {
      print("[AdMobManager] Ads display failure - other ads is showing!")
      didFail?()
      return
    }
    guard checkFrequency(adConfig: adConfig, ad: ad) else {
      print("[AdMobManager] Ads hasn't been displayed yet!")
      didFail?()
      return
    }
    ad.show(rootViewController: rootViewController,
            didFail: didFail,
            didEarnReward: didEarnReward,
            didHide: didHide)
  }
  
  public func requestConsentUpdate() {
    guard let topVC = UIApplication.topStackViewController() else {
      return
    }
    
    UMPConsentForm.presentPrivacyOptionsForm(from: topVC) { [weak self] formError in
      guard let self else {
        return
      }
      if let formError {
        print("[AdMobManager] Form error - \(formError.localizedDescription)!")
        return
      }
      let canShowAds = canShowAds()
      if canShowAds {
        self.startGoogleMobileAdsSDK()
      }
      self.state = canShowAds == true ? .allow : .reject
    }
  }
  
  public func activeDebug(testDeviceIdentifiers: [String], reset: Bool) {
    self.isDebug = true
    self.testDeviceIdentifiers = testDeviceIdentifiers
    if reset {
      UMPConsentInformation.sharedInstance.reset()
    }
  }
}

extension AdMobManager {
  func getAd(type: AdType, name: String) -> Any? {
    guard let adMobConfig else {
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
  
  func getNativePreload(name: String) -> NativeAd? {
    return listNativeAd[name]
  }
}

extension AdMobManager {
  private func checkIsPresent() -> Bool {
    for ad in listReuseAd where ad.value.isPresent() {
      return true
    }
    return false
  }
  
  private func updateAdMobCache() {
    guard let remoteKey else {
      return
    }
    guard let adMobConfig else {
      return
    }
    guard let data = try? JSONEncoder().encode(adMobConfig) else {
      return
    }
    UserDefaults.standard.set(data, forKey: remoteKey)
  }
  
  private func updateConsentCache() {
    guard let consentConfig else {
      return
    }
    guard let data = try? JSONEncoder().encode(consentConfig) else {
      return
    }
    UserDefaults.standard.set(data, forKey: consentKey)
  }
  
  private func decoding(adMobData: Data) {
    guard let adMobConfig = try? JSONDecoder().decode(AdMobConfig.self, from: adMobData) else {
      print("[AdMobManager] Invalid format!")
      return
    }
    self.adMobConfig = adMobConfig
    updateAdMobCache()
    
    if !didRequestConsent {
      self.didRequestConsent = true
      checkConsent()
    }
  }
  
  private func decoding(consentData: Data) {
    guard let consentConfig = try? JSONDecoder().decode(ConsentConfig.self, from: consentData) else {
      print("[AdMobManager] Invalid format!")
      return
    }
    self.consentConfig = consentConfig
    updateConsentCache()
  }
  
  private func fetchAdMobCache() {
    guard let remoteKey else {
      return
    }
    guard let cacheData = UserDefaults.standard.data(forKey: remoteKey) else {
      return
    }
    decoding(adMobData: cacheData)
  }
  
  private func fetchConsentCache() {
    guard let cacheData = UserDefaults.standard.data(forKey: consentKey) else {
      return
    }
    decoding(consentData: cacheData)
  }
  
  private func fetchDefault() {
    guard let defaultData else {
      return
    }
    decoding(adMobData: defaultData)
  }
  
  private func fetchRemote() {
    guard let remoteKey else {
      return
    }
    print("[AdMobManager] Remote config start load!")
    LogEventManager.shared.log(event: .remoteConfigStartLoad)
    DispatchQueue.main.asyncAfter(deadline: .now() + remoteTimeout, execute: timeoutRemote)
    remoteConfig.fetch(withExpirationDuration: 0) { [weak self] _, error in
      guard let self = self else {
        return
      }
      guard error == nil else {
        errorRemote()
        return
      }
      self.remoteConfig.activate()
      self.configValue?(self.remoteConfig)
      let adMobData = remoteConfig.configValue(forKey: remoteKey).dataValue
      let consentData = remoteConfig.configValue(forKey: consentKey).dataValue
      guard !adMobData.isEmpty else {
        errorRemote()
        return
      }
      print("[AdMobManager] Remote config success!")
      LogEventManager.shared.log(event: .remoteConfigSuccess)
      self.decoding(consentData: consentData)
      self.decoding(adMobData: adMobData)
    }
  }
  
  private func errorRemote() {
    guard adMobConfig == nil else {
      if didTimeout {
        print("[AdMobManager] First load remote config error with timeout!")
        LogEventManager.shared.log(event: .remoteConfigErrorWithTimeout)
      }
      return
    }
    print("[AdMobManager] First load remote config error!")
    LogEventManager.shared.log(event: .remoteConfigLoadFail)
    fetchDefault()
  }
  
  private func timeoutRemote() {
    guard adMobConfig == nil else {
      return
    }
    self.didTimeout = true
    print("[AdMobManager] First load remote config timeout!")
    LogEventManager.shared.log(event: .remoteConfigTimeout)
    fetchDefault()
  }
  
  private func checkFrequency(adConfig: AdConfigProtocol, ad: AdProtocol) -> Bool {
    guard
      let interstitial = adConfig as? Interstitial,
      let start = interstitial.start,
      let frequency = interstitial.frequency
    else {
      return true
    }
    let countClick = FrequencyManager.shared.getCount(name: adConfig.name) + 1
    guard countClick >= start else {
      FrequencyManager.shared.increaseCount(name: adConfig.name)
      return false
    }
    let isShow = (countClick - start) % frequency == 0
    if !isShow || ad.isExist!() {
      FrequencyManager.shared.increaseCount(name: adConfig.name)
    }
    return isShow
  }
  
  private func checkConsent() {
    print("[AdMobManager] CMP check consent!")
    LogEventManager.shared.log(event: .cmpCheckConsent)
    guard !isPremium else {
      print("[AdMobManager] CMP not request consent!")
      LogEventManager.shared.log(event: .cmpNotRequestConsent)
      return
    }
    guard let adMobConfig else {
      return
    }
    guard adMobConfig.status else {
      print("[AdMobManager] CMP not request consent!")
      LogEventManager.shared.log(event: .cmpNotRequestConsent)
      allow()
      return
    }
    guard let consentConfig, consentConfig.status else {
      print("[AdMobManager] CMP not request consent!")
      LogEventManager.shared.log(event: .cmpNotRequestConsent)
      allow()
      return
    }
    
    let parameters = UMPRequestParameters()
    parameters.tagForUnderAgeOfConsent = false
    
    if isDebug {
      let debugSettings = UMPDebugSettings()
      debugSettings.testDeviceIdentifiers = testDeviceIdentifiers
      debugSettings.geography = .EEA
      parameters.debugSettings = debugSettings
    }
    print("[AdMobManager] CMP request consent!")
    LogEventManager.shared.log(event: .cmpRequestConsent)
    UMPConsentInformation.sharedInstance.requestConsentInfoUpdate(with: parameters) { [weak self] requestConsentError in
      guard let self else {
        return
      }
      if let requestConsentError {
        print("[AdMobManager] Request consent error - \(requestConsentError.localizedDescription)!")
        LogEventManager.shared.log(event: .cmpConsentInformationError)
        allow()
        return
      }
      
      guard let topVC = UIApplication.topStackViewController() else {
        return
      }
      
      UMPConsentForm.loadAndPresentIfRequired(from: topVC) { [weak self] loadAndPresentError in
        guard let self else {
          return
        }
        if let loadAndPresentError {
          print("[AdMobManager] Load and present error - \(loadAndPresentError.localizedDescription)!")
          LogEventManager.shared.log(event: .cmpConsentFormError)
          allow()
          return
        }
        
        guard isGDPR() else {
          print("[AdMobManager] CMP auto agree consent GDPR!")
          LogEventManager.shared.log(event: .cmpAutoAgreeConsentGDPR)
          allow()
          return
        }
        
        let canShowAds = canShowAds()
        if canShowAds {
          print("[AdMobManager] CMP agree consent!")
          LogEventManager.shared.log(event: .cmpAgreeConsent)
          self.startGoogleMobileAdsSDK()
        } else {
          print("[AdMobManager] CMP reject consent!")
          LogEventManager.shared.log(event: .cmpRejectConsent)
        }
        self.state = canShowAds == true ? .allow : .reject
      }
    }
    
    if canShowAds() {
      print("[AdMobManager] CMP auto agree consent!")
      LogEventManager.shared.log(event: .cmpAutoAgreeConsent)
      allow()
    }
  }
  
  private func allow() {
    self.startGoogleMobileAdsSDK()
    self.state = .allow
  }
  
  private func startGoogleMobileAdsSDK() {
    DispatchQueue.main.async { [weak self] in
      guard let self else {
        return
      }
      guard !didSetup else {
        return
      }
      self.didSetup = true
      
      GADMobileAds.sharedInstance().start()
    }
  }
  
  private func isGDPR() -> Bool {
    let settings = UserDefaults.standard
    let gdpr = settings.integer(forKey: "IABTCF_gdprApplies")
    return gdpr == 1
  }
  
  private func canShowAds() -> Bool {
    let userDefaults = UserDefaults.standard
    
    let purposeConsent = userDefaults.string(forKey: "IABTCF_PurposeConsents") ?? ""
    let vendorConsent = userDefaults.string(forKey: "IABTCF_VendorConsents") ?? ""
    let vendorLI = userDefaults.string(forKey: "IABTCF_VendorLegitimateInterests") ?? ""
    let purposeLI = userDefaults.string(forKey: "IABTCF_PurposeLegitimateInterests") ?? ""
    
    let googleId = 755
    let hasGoogleVendorConsent = hasAttribute(input: vendorConsent, index: googleId)
    let hasGoogleVendorLI = hasAttribute(input: vendorLI, index: googleId)
    
    return hasConsentFor([1], purposeConsent, hasGoogleVendorConsent)
    && hasConsentOrLegitimateInterestFor([2,7,9,10],
                                         purposeConsent,
                                         purposeLI,
                                         hasGoogleVendorConsent,
                                         hasGoogleVendorLI)
  }
  
  private func hasAttribute(input: String, index: Int) -> Bool {
    return input.count >= index && String(Array(input)[index - 1]) == "1"
  }
  
  private func hasConsentFor(_ purposes: [Int], _ purposeConsent: String, _ hasVendorConsent: Bool) -> Bool {
    return purposes.allSatisfy { i in hasAttribute(input: purposeConsent, index: i) } && hasVendorConsent
  }
  
  private func hasConsentOrLegitimateInterestFor(_ purposes: [Int],
                                                 _ purposeConsent: String,
                                                 _ purposeLI: String,
                                                 _ hasVendorConsent: Bool,
                                                 _ hasVendorLI: Bool
  ) -> Bool {
    return purposes.allSatisfy { i in
      (hasAttribute(input: purposeLI, index: i) && hasVendorLI) ||
      (hasAttribute(input: purposeConsent, index: i) && hasVendorConsent)
    }
  }
}
