import UIKit
import GoogleMobileAds
import Foundation

/// An ad management structure. It supports setting SplashAd, InterstitialAd, AppOpenAd, NativeAd, BannerAd.
/// ```
/// import AdMobManager
/// ```
/// - Warning: Available for Swift 5.0, Xcode 11.0. Support from iOS 10.0!
public struct AdMobManager {
    
    public static var shared = AdMobManager()
    
    public enum AdType {
        case splash
        case interstitial
        case appOpen
    }
    
    fileprivate var splashAd = SplashAd()
    fileprivate var interstitialAd = InterstitialAd()
    fileprivate var appOpenAd = AppOpenAd()
    fileprivate var startDate: Date?
    fileprivate var nativeAd_ID: String?
    fileprivate var bannerAd_ID: String?
    fileprivate var limitReloadingOfAdsWhenThereIsAnError: Bool = false
    fileprivate var stopLoadingSplashAd: Bool = false
    
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
            self.splashAd.setAdUnitID(ID: splashAd_ID)
        }
        
        if let interstitialAd_ID = interstitialAd_ID {
            self.interstitialAd.setAdUnitID(ID: interstitialAd_ID)
        }
        
        if let appOpenAd_ID = appOpenAd_ID {
            self.appOpenAd.setAdUnitID(ID: appOpenAd_ID)
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
            self.interstitialAd.setTimeBetween(time: time)
        case .appOpen:
            self.appOpenAd.setTimeBetween(time: time)
        default:
            return
        }
    }
    
    /// This function helps to limit the reload of the ad when an error occurs.
    ///```
    /// func applicationDidBecomeActive(_ application: UIApplication) {
    ///     AdMobManager.shared.limit_Reloading_Of_Ads_When_There_Is_An_Error()
    /// }
    ///
    /// func sceneDidBecomeActive(_ scene: UIScene) {
    ///     AdMobManager.shared.limit_Reloading_Of_Ads_When_There_Is_An_Error()
    /// }
    ///```
    /// - Warning: Ads may not be displayed properly. Changes only for SplashAd, InterstitialAd, AppOpenAd.
    public mutating func limit_Reloading_Of_Ads_When_There_Is_An_Error() {
        self.limitReloadingOfAdsWhenThereIsAnError = true
        self.load()
    }
    
    /// This function helps to block reloading of SplashAd.
    /// ```
    /// AdMobManager.shared.stop_Loading_SplashAd()
    /// ```
    /// Recommended when splash ads don't need to appear anymore.
    public mutating func stop_Loading_SplashAd() {
        self.stopLoadingSplashAd = true
    }
}

extension AdMobManager {
    func load() {
        if !self.allowShowFullFeature() {
            return
        }
        
        if !self.splashAd.isExist() {
            self.splashAd.load()
        }
        
        if !self.interstitialAd.isExist() {
            self.interstitialAd.load()
        }
        
        if !self.appOpenAd.isExist() {
            self.appOpenAd.load()
        }
    }
    
    func getNativeAdID() -> String? {
        return self.nativeAd_ID
    }
    
    func getBannerAdID() -> String? {
        return self.bannerAd_ID
    }
    
    func getLimitReloadingOfAdsWhenThereIsAnError() -> Bool {
        return self.limitReloadingOfAdsWhenThereIsAnError
    }
    
    func getStopLoadingSplashAd() -> Bool {
        return self.stopLoadingSplashAd
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
