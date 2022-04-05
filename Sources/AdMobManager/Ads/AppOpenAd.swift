//
//  AppOpenAd.swift
//  AdMobManager
//
//  Created by Trịnh Xuân Minh on 25/03/2022.
//

import Foundation
import UIKit
import GoogleMobileAds

class AppOpenAd: NSObject {
    
    public var adUnit_ID: String?
    fileprivate var appOpenAd: GADAppOpenAd?
    fileprivate var loadTimeOpenApp: Date = Date()
    public var timeBetween: Double = 5
    fileprivate var isLoading: Bool = false
    fileprivate var willPresent: (() -> ())?
    fileprivate var willDismiss: (() -> ())?
    fileprivate var didDismiss: (() -> ())?
    public var adReloadTime: Double = 1.0
    fileprivate var loadRequestWorkItem: DispatchWorkItem?
    
    func load() {
        if self.isLoading {
            return
        }
        
        if self.isExist() {
            return
        }
        
        if #available(iOS 12.0, *), !NetworkMonitor.shared.isConnected {
            print("Not connected!")
            self.request()
            return
        }
        
        guard let adUnit_ID = self.adUnit_ID else {
            print("No AppOpenAd ID!")
            return
        }
        
        self.isLoading = true
        
        let request = GADRequest()
        GADAppOpenAd.load(withAdUnitID: adUnit_ID,
                          request: request,
                          orientation: UIInterfaceOrientation.portrait) { (ad, error) in
            self.isLoading = false
            if let _ = error {
                print("AppOpenAd download error, trying again!")
                return
            }
            self.appOpenAd = ad
            self.appOpenAd?.fullScreenContentDelegate = self
        }
    }
    
    func request() {
        DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(Int(self.adReloadTime * 1000)), execute: self.load)
    }
    
    func isExist() -> Bool {
        return self.appOpenAd != nil
    }
    
    func isReady() -> Bool {
        return self.isExist() && self.wasLoadTimeLessThanNHoursAgo()
    }
    
    func show(willPresent: (() -> ())?, willDismiss: (() -> ())?, didDismiss: (() -> ())?) {
        if !self.isReady() {
            print("AppOpenAd are not ready to show!")
            if #available(iOS 12.0, *) {
            } else {
                self.load()
            }
            return
        }
        guard let topViewController = UIApplication.topStackViewController() else {
            print("Can't find RootViewController!")
            return
        }
        self.willPresent = willPresent
        self.willDismiss = willDismiss
        self.didDismiss = didDismiss
        self.appOpenAd?.present(fromRootViewController: topViewController)
    }
}

extension AppOpenAd: GADFullScreenContentDelegate {
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad did fail to present full screen content.")
        self.didDismiss?()
    }
    
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        self.willPresent?()
    }
    
    func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        self.willDismiss?()
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did dismiss full screen content.")
        self.didDismiss?()
        self.appOpenAd = nil
        self.load()
        self.loadTimeOpenApp = Date()
    }
    
    func wasLoadTimeLessThanNHoursAgo() -> Bool {
        let now = Date()
        let timeIntervalBetweenNowAndLoadTime = now.timeIntervalSince(self.loadTimeOpenApp)
        return timeIntervalBetweenNowAndLoadTime > self.timeBetween
    }
}
