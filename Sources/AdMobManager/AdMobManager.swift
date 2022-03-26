import UIKit
import GoogleMobileAds
import Foundation

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
    
    public mutating func set_AdUnit(splashAd_ID: String? = nil, interstitialAd_ID: String? = nil, appOpenAd_ID: String? = nil, nativeAd_ID: String? = nil) {
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
        
        self.load()
    }
    
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
    
    public mutating func set_Time_Show_Full_Feature(start: Date) {
        self.startDate = start
    }
    
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
