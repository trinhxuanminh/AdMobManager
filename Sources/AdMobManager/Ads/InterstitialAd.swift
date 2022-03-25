//
//  InterstitialAdsGlobal.swift
//  MovieIOS7
//
//  Created by Trịnh Xuân Minh on 21/02/2022.
//

import Foundation
import UIKit
import GoogleMobileAds

class InterstitialAd: NSObject {
    
    fileprivate var adUnit_ID: String?
    fileprivate var interstitialAd: GADInterstitialAd?
    fileprivate var timer: Timer?
    fileprivate var time: Double = 0.0
    fileprivate var adsReady: Bool = true
    fileprivate var timeInterval: Double = 0.1
    fileprivate var timeBetween: Double = 5
    fileprivate var isLoading: Bool = false
    fileprivate var willDismiss: (() -> ())?
    fileprivate var didDismiss: (() -> ())?
    
    func load() {
        if self.isLoading {
            return
        }
        self.isLoading = true
        
        guard let adUnit_ID = adUnit_ID else {
            return
        }
        
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: adUnit_ID,
                               request: request) { (ad, error) in
            if let _ = error {
                print("InterstitialAds download error, trying again!")
                self.isLoading = false
                self.load()
                return
            }
            self.interstitialAd = ad
            self.interstitialAd?.fullScreenContentDelegate = self
            self.isLoading = false
        }
    }
    
    func isExist() -> Bool {
        return self.interstitialAd != nil
    }
    
    func isReady() -> Bool {
        return self.isExist() && self.adsReady
    }
    
    func show(rootViewController: UIViewController, willDismiss: (() -> ())?, didDismiss: (() -> ())?) {
        if !self.isReady() {
            print("InterstitialAds are not ready to show!")
            return
        }
        self.willDismiss = willDismiss
        self.didDismiss = didDismiss
        self.interstitialAd?.present(fromRootViewController: rootViewController)
    }
}

extension InterstitialAd: GADFullScreenContentDelegate {
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad did fail to present full screen content.")
        self.didDismiss?()
    }
    
    func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        self.willDismiss?()
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did dismiss full screen content.")
        self.didDismiss?()
        self.interstitialAd = nil
        self.load()
        self.adsReady = false
        self.time = 0
        self.timer = Timer.scheduledTimer(timeInterval: self.timeInterval, target: self, selector: #selector(runTime), userInfo: nil, repeats: true)
    }
    
    @objc func runTime() {
        self.time += self.timeInterval
        if self.time >= self.timeBetween {
            self.adsReady = true
            self.timer?.invalidate()
            self.timer = nil
        }
    }
    
    func setTimeBetween(time: Double) {
        self.timeBetween = time
    }
    
    func set_AdUnit_ID(ID: String) {
        self.adUnit_ID = ID
    }
}
