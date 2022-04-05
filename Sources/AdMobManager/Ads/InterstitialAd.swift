//
//  InterstitialAd.swift
//  AdMobManager
//
//  Created by Trịnh Xuân Minh on 25/03/2022.
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
    fileprivate var willPresent: (() -> ())?
    fileprivate var willDismiss: (() -> ())?
    fileprivate var didDismiss: (() -> ())?
    fileprivate var adReloadTime: Int = 1000
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
            print("No InterstitialAd ID!")
            return
        }
        
        self.isLoading = true
        
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: adUnit_ID,
                               request: request) { (ad, error) in
            self.isLoading = false
            if let _ = error {
                print("InterstitialAd download error, trying again!")
                return
            }
            self.interstitialAd = ad
            self.interstitialAd?.fullScreenContentDelegate = self
        }
    }
    
    func request() {
        DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(self.adReloadTime), execute: self.load)
    }
    
    func isExist() -> Bool {
        return self.interstitialAd != nil
    }
    
    func isReady() -> Bool {
        return self.isExist() && self.adsReady
    }
    
    func show(willPresent: (() -> ())?, willDismiss: (() -> ())?, didDismiss: (() -> ())?) {
        if !self.isReady() {
            print("InterstitialAd are not ready to show!")
            if #available(*, iOS 11.4) {
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
        self.interstitialAd?.present(fromRootViewController: topViewController)
    }
}

extension InterstitialAd: GADFullScreenContentDelegate {
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
    
    func setAdUnitID(ID: String) {
        self.adUnit_ID = ID
    }
    
    func setAdReloadTime(time: Int) {
        self.adReloadTime = time
    }
}
