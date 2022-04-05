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
    
    fileprivate var adUnit_ID: String?
    fileprivate var splashAd: GADInterstitialAd?
    fileprivate var willPresent: (() -> ())?
    fileprivate var willDismiss: (() -> ())?
    fileprivate var didDismiss: (() -> ())?
    fileprivate var stopLoadingSplashAd: Bool = false
    fileprivate var loadRequestWorkItem: DispatchWorkItem?
    
    func load() {
        if self.stopLoadingSplashAd {
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
        
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: adUnit_ID,
                               request: request) { (ad, error) in
            if let _ = error {
                print("SplashAd download error, trying again!")
                self.request()
                return
            }
            self.splashAd = ad
            self.splashAd?.fullScreenContentDelegate = self
        }
    }
    
    func request() {
        self.loadRequestWorkItem?.cancel()
        let requestWorkItem = DispatchWorkItem(block: self.load)
        self.loadRequestWorkItem = requestWorkItem
        let adReloadTime: Int? = AdMobManager.shared.getAdReloadTime()
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(adReloadTime == nil ? 0 : adReloadTime!), execute: requestWorkItem)
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
        self.willPresent?()
    }
    
    func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        self.willDismiss?()
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did dismiss full screen content.")
        self.didDismiss?()
    }
    
    func setAdUnitID(ID: String) {
        self.adUnit_ID = ID
    }
    
    func setStopLoadingSplashAd() {
        self.stopLoadingSplashAd = true
    }
}
