import UIKit
import GoogleMobileAds
import Foundation
import NativeAdCollectionViewCell

public struct AdMobManager {
    
    public static var shared = AdMobManager()
    
    fileprivate var splashAd = SplashAd()
    fileprivate var interstitialAd = InterstitialAd()
    fileprivate var appOpenAd = AppOpenAd()
    fileprivate var startDate: Date?
    
    public enum AdType {
        case splash
        case interstitial
        case appOpen
        case native
    }
    
    public mutating func set_AdUnit(splashID: String?, interstitialID: String?, appOpenID: String?) {
        if let splashID = splashID {
            self.splashAd.set_AdUnit_ID(ID: splashID)
        }
        
        if let interstitialID = interstitialID {
            self.interstitialAd.set_AdUnit_ID(ID: interstitialID)
        }
        
        if let appOpenID = appOpenID {
            self.appOpenAd.set_AdUnit_ID(ID: appOpenID)
        }
        
        self.load()
    }
    
    public func isReady(adType: AdType) -> Bool {
        switch adType {
        case .splash:
            return self.splashAd.isReady()
        case .interstitial:
            return self.interstitialAd.isReady()
        case .appOpen:
            return self.appOpenAd.isReady()
        case .native:
            return false
        }
    }
    
    public func show(adType: AdType, rootViewController: UIViewController, willDismiss: (() -> ())? = {}, didDismiss: (() -> ())? = {}) {
        switch adType {
        case .splash:
            self.splashAd.show(rootViewController: rootViewController, willDismiss: willDismiss, didDismiss: didDismiss)
        case .interstitial:
            self.interstitialAd.show(rootViewController: rootViewController, willDismiss: willDismiss, didDismiss: didDismiss)
        case .appOpen:
            self.appOpenAd.show(rootViewController: rootViewController, willDismiss: willDismiss, didDismiss: didDismiss)
        case .native:
            return
        }
    }
    
    public mutating func set_Time_Show_Full_Feature(start: Date) {
        self.startDate = start
    }
    
    public func setTimeBetween(adType: AdType, time: Double) {
        switch adType {
        case .interstitial:
            self.interstitialAd.setTimeBetween(time: time)
        case .appOpen:
            self.appOpenAd.setTimeBetween(time: time)
        default:
            return
        }
    }
    
    public func nativeAd() -> NativeAd {
        return NativeAd()
    }
}

extension AdMobManager {
    func load() {
        if !self.allow_Show_Full_Feature() {
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
    
    func allow_Show_Full_Feature() -> Bool {
        guard let startDate = self.startDate else {
            return true
        }
        
        if Date().timeIntervalSince(startDate) > 0 {
            return true
        }
        return false
    }
}
