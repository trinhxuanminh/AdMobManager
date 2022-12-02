//
//  AdMobManager.swift
//  AdMobManager
//
//  Created by Trịnh Xuân Minh on 25/03/2022.
//

import UIKit
import GoogleMobileAds
import Foundation

/// An ad management structure. It supports setting InterstitialAd, RewardAd, AppOpenAd, NativeAd, BannerAd.
/// ```
/// import AdMobManager
/// ```
/// - Warning: Available for Swift 5.3, Xcode 12.5 (macOS Big Sur). Support from iOS 10.0 or newer.
public struct AdMobManager {
  /// This constant returns the Bundle of the AdMobManager module
  public static let bundle = Bundle.module
  public static var shared = AdMobManager()
  
  public enum AdType: Int {
    case interstitial
    case reward
    case appOpen
  }
  
  private var ads: [AdProtocol] = [InterstitialAd(), RewardAd(), AppOpenAd()]
  private var startDate: Date?
  private var nativeID: String?
  private var bannerID: String?
  
  /// This function helps to change the ad ID, available for the next load.
  /// ```
  /// AdMobManager.shared.setID(
  ///   interstitial: "ca-app-pub-3940256099942544/4411468910",
  ///   reward: "ca-app-pub-3940256099942544/1712485313",
  ///   appOpen: "ca-app-pub-3940256099942544/5662855259",
  ///   native: "ca-app-pub-3940256099942544/3986624511",
  ///   banner: "ca-app-pub-3940256099942544/2934735716")
  /// ```
  /// - Warning: Ad parameters = nil will not load the corresponding ad type.
  public mutating func setID(
    interstitial: String? = nil,
    reward: String? = nil,
    appOpen: String? = nil,
    native: String? = nil,
    banner: String? = nil
  ) {
    if let native = native {
      self.nativeID = native
    }
    if let banner = banner {
      self.bannerID = banner
    }
    guard allowShowFullFeature() else {
      print("Ads are not allowed to load!")
      return
    }
    if let interstitial = interstitial {
      ads[0].setAdUnitID(interstitial)
    }
    if let reward = reward {
      ads[1].setAdUnitID(reward)
    }
    if let appOpen = appOpen {
      ads[2].setAdUnitID(appOpen)
    }
  }
  
  /// This function returns a value indicating if the ad is ready to be displayed.
  public func isReady(ad type: AdType) -> Bool {
    return ads[type.rawValue].isReady()
  }
  
  /// This function will display ads when ready.
  /// - Parameter willPresent: The block executes after the ad is about to show.
  /// - Parameter willDismiss: The block executes after the ad is about to disappear.
  /// - Parameter didDismiss: The block executes after the ad has disappeared.
  /// - Parameter didFail: The block executes after the ad has fail to show content.
  public func show(
    ad type: AdType,
    willPresent: (() -> Void)? = nil,
    willDismiss: (() -> Void)? = nil,
    didDismiss: (() -> Void)? = nil,
    didFail: (() -> Void)? = nil
  ) {
    if type == .appOpen {
      guard !ads[0].isPresent() else {
        print("AppOpenAd: display failure - InterstitialAd is showing!")
        return
      }
      guard !ads[1].isPresent() else {
        print("AppOpenAd: display failure - RewardedAd is showing!")
        return
      }
    }
    ads[type.rawValue].show(willPresent: willPresent,
                            willDismiss: willDismiss,
                            didDismiss: didDismiss,
                            didFail: didFail)
  }
  
  /// This function helps to set the date to start showing ads.
  /// Use before setID ad.
  /// - Warning: Default is **nil**, ad can be displayed as soon as it's ready.
  /// Changes only for InterstitialAd, RewardAd, AppOpenAd.
  public mutating func showFullFeature(from date: Date) {
    self.startDate = date
  }
  
  /// This function helps to change the minimum display time between ads of the same type.
  /// ```
  /// AdMobManager.shared.setTimeBetween(10.0, ad: .interstitial)
  /// ```
  /// - Parameter time: Minimum time between ads. Default is **10 seconds**.
  /// - Warning: Changes only for InterstitialAd, RewardAd, AppOpenAd.
  public func setTimeBetween(_ time: Double, ad type: AdType) {
    ads[type.rawValue].setTimeBetween(time)
  }
}

extension AdMobManager {
  func getNativeID() -> String? {
    return nativeID
  }
  
  func getBannerID() -> String? {
    return bannerID
  }
  
  private func allowShowFullFeature() -> Bool {
    guard let startDate = startDate, Date().timeIntervalSince(startDate) < 0 else {
      return true
    }
    return false
  }
}
