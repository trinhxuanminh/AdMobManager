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
    
    /// Interface style for ad content.
    public enum Style {
        /// This style will display white labels on a dark theme.
        case dark
        /// This style will display black labels on a dark theme.
        case light
    }
    
    fileprivate var splashAd = SplashAd()
    fileprivate var interstitialAd = InterstitialAd()
    fileprivate var appOpenAd = AppOpenAd()
    fileprivate var startDate: Date?
    fileprivate var nativeAd_ID: String?
    fileprivate var bannerAd_ID: String?
    fileprivate var adReloadTime: Double = 1.0
    
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
    public mutating func set_AdUnit(splashAd_ID: String? = nil, interstitialAd_ID: String? = nil, appOpenAd_ID: String? = nil, nativeAd_ID: String? = nil, bannerAd_ID: String? = nil) {
        if let splashAd_ID = splashAd_ID {
            self.splashAd.adUnit_ID = splashAd_ID
        }
        
        if let interstitialAd_ID = interstitialAd_ID {
            self.interstitialAd.adUnit_ID = interstitialAd_ID
        }
        
        if let appOpenAd_ID = appOpenAd_ID {
            self.appOpenAd.adUnit_ID = appOpenAd_ID
        }
        
        if let nativeAd_ID = nativeAd_ID {
            self.nativeAd_ID = nativeAd_ID
        }
        
        if let bannerAd_ID = bannerAd_ID {
            self.bannerAd_ID = bannerAd_ID
        }
        
        self.load()
    }
    
    /// This function returns a value indicating if the ad is ready to be displayed.
    /// ```
    /// AdMobManager.shared.is_Ready(adType: .splash)
    /// ```
    public func is_Ready(adType: AdType) -> Bool {
        switch adType {
        case .splash:
            return self.splashAd.isReady()
        case .interstitial:
            return self.interstitialAd.isReady()
        case .appOpen:
            return self.appOpenAd.isReady()
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
    public func show(adType: AdType, willPresent: (() -> ())? = nil, willDismiss: (() -> ())? = nil, didDismiss: (() -> ())? = nil) {
        switch adType {
        case .splash:
            self.splashAd.show(willPresent: willPresent, willDismiss: willDismiss, didDismiss: didDismiss)
        case .interstitial:
            self.interstitialAd.show(willPresent: willPresent, willDismiss: willDismiss, didDismiss: didDismiss)
        case .appOpen:
            if self.splashAd.isPresent {
                print("SplashAd is showing!")
                return
            } else if self.interstitialAd.isPresent {
                print("InterstitialAd is showing!")
                return
            }
            self.appOpenAd.show(willPresent: willPresent, willDismiss: willDismiss, didDismiss: didDismiss)
        }
    }
    
    /// This function helps to set the date to start showing ads.
    /// - Warning: Default is **nil**, the ad will be displayed as soon as it is ready. Changes only for SplashAd, InterstitialAd, AppOpenAd.
    public mutating func set_Time_Show_Full_Feature(start: Date) {
        self.startDate = start
    }
    
    /// This function helps to change the minimum display time between ads of the same type.
    ///```
    /// AdMobManager.shared.set_Time_Between(adType: .interstitial, time: 5.0)
    ///```
    /// - Parameter time: Minimum time between ads. Default is **5 seconds**.
    /// - Warning: Changes only for  InterstitialAd, AppOpenAd.
    public func set_Time_Between(adType: AdType, time: Double) {
        switch adType {
        case .interstitial:
            self.interstitialAd.timeBetween = time
        case .appOpen:
            self.appOpenAd.timeBetween = time
        default:
            return
        }
    }
    
    /// This function helps to limit the reload of the ad when an error occurs.
    ///```
    /// AdMobManager.shared.limit_Reloading_Of_Ads_When_There_Is_An_Error(adReloadTime: 1.0)
    ///```
    /// - Parameter adReloadTime: Time reload ads after failed load. Default is **1 seconds**.
    public mutating func limit_Reloading_Of_Ads_When_There_Is_An_Error(adReloadTime: Double) {
        self.adReloadTime = adReloadTime
        
        self.splashAd.adReloadTime = adReloadTime
        
        self.interstitialAd.adReloadTime = adReloadTime
        
        self.appOpenAd.adReloadTime = adReloadTime
    }
    
    /// This function helps to block reloading of SplashAd.
    /// ```
    /// AdMobManager.shared.stop_Loading_SplashAd()
    /// ```
    /// Recommended when splash ads don't need to appear anymore.
    public mutating func stop_Loading_SplashAd() {
        self.splashAd.setStopLoadingSplashAd()
    }
    
    /// This function return about an value for know the path is available to establish connections and send data.
    /// ```
    /// AdMobManager.shared.isConnected()
    /// ```
    /// - Warning: Available for iOS 12.0 or newer.
    @available(iOS 12.0, *)
    public func isConnected() -> Bool {
        return NetworkMonitor.shared.isConnected
    }
}

extension AdMobManager {
    func load() {
        if !self.allowShowFullFeature() {
            return
        }
        
        self.splashAd.load()
        
        self.interstitialAd.load()
        
        self.appOpenAd.load()
    }
    
    func getNativeAdID() -> String? {
        return self.nativeAd_ID
    }
    
    func getBannerAdID() -> String? {
        return self.bannerAd_ID
    }
    
    func getAdReloadTime() -> Double {
        return self.adReloadTime
    }
    
    func allowShowFullFeature() -> Bool {
        guard let startDate = self.startDate else {
            return true
        }
        
        if Date().timeIntervalSince(startDate) > 0 {
            return true
        }
        return false
    }
}
