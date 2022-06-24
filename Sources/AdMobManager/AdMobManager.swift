//
//  AdMobManager.swift
//  AdMobManager
//
//  Created by Trịnh Xuân Minh on 25/03/2022.
//

import UIKit
import GoogleMobileAds
import Foundation

/// An ad management structure. It supports setting SplashAd, InterstitialAd, AppOpenAd, NativeAd, BannerAd.
/// ```
/// import AdMobManager
/// ```
/// - Warning: Available for Swift 5.3, Xcode 12.0 (macOS Big Sur). Support from iOS 10.0 or newer.
public struct AdMobManager {

  /// This constant returns the Bundle of the AdMobManager module
  public static let bundle = Bundle.module

  public static var shared = AdMobManager()

  public enum AdType {
    case splash
    case interstitial
    case appOpen
  }

  public enum ReuseAdType {
    case interstitial
    case appOpen
  }

  public enum OnceAdType {
    case splash
  }

  private var splashAd: OnceAdProtocol = SplashAd()
  private var interstitialAd: ReuseAdProtocol = InterstitialAd()
  private var appOpenAd: ReuseAdProtocol = AppOpenAd()
  private var startDate: Date?
  private var nativeID: String?
  private var bannerID: String?
  private var adReloadTime = 1.0

  /// This function helps to change the ad ID, available for the next load.
  /// ```
  /// func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
  ///
  ///     let bannerId = "ca-app-pub-3940256099942544/2934735716"
  ///     let interstitialID = "ca-app-pub-3940256099942544/4411468910"
  ///     let splashID = "ca-app-pub-3940256099942544/4411468910"
  ///     let nativeID = "ca-app-pub-3940256099942544/3986624511"
  ///     let appOpenID = "ca-app-pub-3940256099942544/5662855259"
  ///
  ///     AdMobManager.shared.set_AdUnit(splashAd_ID: splashID, interstitialAd_ID: interstitialID, appOpenAd_ID: appOpenID, nativeAd_ID: nativeID, bannerAd_ID: bannerId)
  ///
  ///     return true
  /// }
  /// ```
  /// - Warning: Ad parameters = nil will not load the corresponding ad type.
  public mutating func setID(
    splashID: String? = nil,
    interstitialID: String? = nil,
    appOpenID: String? = nil,
    nativeID: String? = nil,
    bannerID: String? = nil
  ) {
    if let splashID = splashID {
      splashAd.setAdUnitID(splashID)
      load(ad: .splash)
    }

    if let interstitialID = interstitialID {
      interstitialAd.setAdUnitID(interstitialID)
      load(ad: .interstitial)
    }

    if let appOpenID = appOpenID {
      appOpenAd.setAdUnitID(appOpenID)
      load(ad: .appOpen)
    }

    if let nativeID = nativeID {
      self.nativeID = nativeID
    }

    if let bannerID = bannerID {
      self.bannerID = bannerID
    }
  }

  /// This function returns a value indicating if the ad is ready to be displayed.
  /// ```
  /// AdMobManager.shared.is_Ready(adType: .splash)
  /// ```
  public func isReady(ad type: AdType) -> Bool {
    switch type {
    case .splash:
      return splashAd.isReady()
    case .interstitial:
      return interstitialAd.isReady()
    case .appOpen:
      return appOpenAd.isReady()
    }
  }

  /// This function will display ads when ready.
  ///```
  /// AdMobManager.shared.show(adType: .splash)
  ///```
  ///```
  /// AdMobManager.shared.show(adType: .interstitial)
  ///```
  ///```
  /// func applicationDidBecomeActive(_ application: UIApplication) {
  ///     AdMobManager.shared.show(adType: .appOpen)
  /// }
  ///
  /// func sceneDidBecomeActive(_ scene: UIScene) {
  ///     AdMobManager.shared.show(adType: .appOpen)
  /// }
  ///```
  /// - Parameter willPresent: The block executes after the ad is about to show.
  /// - Parameter willDismiss: The block executes after the ad is about to disappear.
  /// - Parameter didDismiss: The block executes after the ad has disappeared.
  public func show(
    ad type: AdType,
    willPresent: (() -> Void)? = nil,
    willDismiss: (() -> Void)? = nil,
    didDismiss: (() -> Void)? = nil
  ) {
    switch type {
    case .splash:
      splashAd.show(
        willPresent: willPresent,
        willDismiss: willDismiss,
        didDismiss: didDismiss)
    case .interstitial:
      interstitialAd.show(
        willPresent: willPresent,
        willDismiss: willDismiss,
        didDismiss: didDismiss)
    case .appOpen:
      guard !splashAd.isPresent() else {
        print("SplashAd is showing!")
        return
      }
      guard !interstitialAd.isPresent() else {
        print("InterstitialAd is showing!")
        return
      }
      appOpenAd.show(
        willPresent: willPresent,
        willDismiss: willDismiss,
        didDismiss: didDismiss)
    }
  }

  /// This function helps to set the date to start showing ads.
  /// - Warning: Default is **nil**, the ad will be displayed as soon as it is ready. Changes only for SplashAd, InterstitialAd, AppOpenAd.
  public mutating func showFullFeature(from date: Date) {
    self.startDate = date
  }

  /// This function helps to change the minimum display time between ads of the same type.
  ///```
  /// AdMobManager.shared.set_Time_Between(adType: .interstitial, time: 5.0)
  ///```
  /// - Parameter time: Minimum time between ads. Default is **5 seconds**.
  /// - Warning: Changes only for  InterstitialAd, AppOpenAd.
  public func setTimeBetween(_ time: Double, ad type: ReuseAdType) {
    switch type {
    case .interstitial:
      interstitialAd.setTimeBetween(time)
    case .appOpen:
      appOpenAd.setTimeBetween(time)
    }
  }

  /// This function helps to limit the reload of the ad when an error occurs.
  ///```
  /// AdMobManager.shared.limit_Reloading_Of_Ads_When_There_Is_An_Error(adReloadTime: 1.0)
  ///```
  /// - Parameter adReloadTime: Time reload ads after failed load. Default is **1 seconds**.
  public mutating func reloadingOfAds(after time: Double) {
    adReloadTime = time

    splashAd.setAdReloadTime(time)

    interstitialAd.setAdReloadTime(time)

    appOpenAd.setAdReloadTime(time)
  }

  /// This function helps to block reloading of SplashAd.
  /// ```
  /// AdMobManager.shared.stop_Loading_SplashAd()
  /// ```
  /// Recommended when splash ads don't need to appear anymore.
  public mutating func stopLoading(ad type: OnceAdType) {
    switch type {
    case .splash:
      splashAd.stopLoading()
    }
  }

  /// This function return about an value for know the path is available to establish connections and send data.
  /// ```
  /// AdMobManager.shared.isConnected()
  /// ```
  /// - Warning: Available for iOS 12.0 or newer.
  @available(iOS 12.0, *)
  public func isConnected() -> Bool {
    return NetworkMonitor.shared.isConnected()
  }
}

extension AdMobManager {
  func load(ad type: AdType) {
    if !allowShowFullFeature() {
      return
    }
    switch type {
    case .splash:
      splashAd.load()
    case .interstitial:
      interstitialAd.load()
    case .appOpen:
      appOpenAd.load()
    }
  }

  func getNativeID() -> String? {
    return nativeID
  }

  func getBannerID() -> String? {
    return bannerID
  }

  func getAdReloadTime() -> Double {
    return adReloadTime
  }

  func allowShowFullFeature() -> Bool {
    guard let startDate = startDate else {
      return true
    }

    if Date().timeIntervalSince(startDate) > 0 {
      return true
    }
    return false
  }
}
