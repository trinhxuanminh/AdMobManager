//
//  SplashAd.swift
//  AdMobManager
//
//  Created by Trịnh Xuân Minh on 25/03/2022.
//

import Foundation
import UIKit
import GoogleMobileAds

class SplashAd: NSObject {
    
    public var adUnit_ID: String?
    fileprivate var splashAd: GADInterstitialAd?
    fileprivate var willPresent: (() -> ())?
    fileprivate var willDismiss: (() -> ())?
    fileprivate var didDismiss: (() -> ())?
    fileprivate var stopLoadingSplashAd: Bool = false
    public var adReloadTime: Double = 1.0
    fileprivate var isLoading: Bool = false
    fileprivate var loadRequestWorkItem: DispatchWorkItem?
    public fileprivate(set) var isPresent: Bool = false
    
    func load() {
        if self.stopLoadingSplashAd {
            return
        }
        
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
            print("No SplashAd ID!")
            return
        }
        
        self.isLoading = true
        
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: adUnit_ID,
                               request: request) { (ad, error) in
            self.isLoading = false
            if let _ = error {
                print("SplashAd download error, trying again!")
                return
            }
            self.splashAd = ad
            self.splashAd?.fullScreenContentDelegate = self
        }
    }
    
    func request() {
        DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(Int(self.adReloadTime * 1000)), execute: self.load)
    }

    func isExist() -> Bool {
        return self.splashAd != nil
    }
    
    func isReady() -> Bool {
        return self.isExist()
    }
    
    func show(willPresent: (() -> ())?, willDismiss: (() -> ())?, didDismiss: (() -> ())?) {
        if !self.isReady() {
            print("SplashAd are not ready to show!")
            return
        }
        guard let topViewController = UIApplication.topStackViewController() else {
            print("Can't find RootViewController!")
            return
        }
        self.willPresent = willPresent
        self.willDismiss = willDismiss
        self.didDismiss = didDismiss
        self.splashAd?.present(fromRootViewController: topViewController)
    }
}

extension SplashAd: GADFullScreenContentDelegate {
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad did fail to present full screen content.")
        self.didDismiss?()
    }
    
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        self.isPresent = true
        self.willPresent?()
    }
    
    func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        self.willDismiss?()
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did dismiss full screen content.")
        self.isPresent = false
        self.didDismiss?()
    }
    
    func setStopLoadingSplashAd() {
        self.stopLoadingSplashAd = true
    }
}
