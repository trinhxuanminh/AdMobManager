//
//  InterstitialAdsSplash.swift
//  MovieIOS7
//
//  Created by Trịnh Xuân Minh on 21/02/2022.
//

import Foundation
import UIKit
import GoogleMobileAds

class SplashAd: NSObject {
    
    fileprivate var adUnit_ID: String?
    fileprivate var splashAd: GADInterstitialAd?
    fileprivate var isLoading: Bool = false
    fileprivate var willPresent: (() -> ())?
    fileprivate var willDismiss: (() -> ())?
    fileprivate var didDismiss: (() -> ())?
    
    func load() {
        if self.isLoading {
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
            if let _ = error {
                print("SplashAds download error, trying again!")
                self.isLoading = false
                self.load()
                return
            }
            self.splashAd = ad
            self.splashAd?.fullScreenContentDelegate = self
            self.isLoading = false
        }
    }

    func isExist() -> Bool {
        return self.splashAd != nil
    }
    
    func isReady() -> Bool {
        return self.isExist()
    }
    
    func show(willPresent: (() -> ())?, willDismiss: (() -> ())?, didDismiss: (() -> ())?) {
        if !self.isReady() {
            print("SplashAds are not ready to show!")
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
}
