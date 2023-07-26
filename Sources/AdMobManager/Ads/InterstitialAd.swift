//
//  InterstitialAd.swift
//  AdMobManager
//
//  Created by Trịnh Xuân Minh on 25/03/2022.
//

import UIKit
import GoogleMobileAds

class InterstitialAd: NSObject, AdProtocol {
  private var interstitialAd: GADInterstitialAd?
  private var adUnitID: String?
  private var timeBetween = 0.0
  private var presentState = false
  private var lastTimeDisplay = Date()
  private var isLoading = false
  private var retryAttempt = 0
  private var isOnceUsed = false
  private var willPresent: Handler?
  private var willDismiss: Handler?
  private var didDismiss: Handler?
  private var didFail: Handler?
  
  func setAdUnitID(_ id: String, isOnceUsed: Bool) {
    guard adUnitID == nil else {
      return
    }
    self.adUnitID = id
    self.isOnceUsed = isOnceUsed
    load()
  }
  
  func setTimeBetween(_ timeBetween: Double) {
    guard timeBetween >= 0.0 else {
      print("InterstitialAd: set time between failed - invalid time!")
      return
    }
    self.timeBetween = timeBetween
  }
  
  func isPresent() -> Bool {
    return presentState
  }
  
  func load() {
    guard !isLoading else {
      return
    }
    
    guard !isExist() else {
      return
    }
    
    guard let adUnitID = adUnitID else {
      print("InterstitialAd: failed to load - not initialized yet! Please install ID.")
      return
    }
    
    DispatchQueue.main.async { [weak self] in
      guard let self = self else {
        return
      }
      
      self.isLoading = true
      print("InterstitialAd: start load!")
      
      let request = GADRequest()
      GADInterstitialAd.load(
        withAdUnitID: adUnitID,
        request: request
      ) { [weak self] (ad, error) in
        guard let self = self else {
          return
        }
        self.isLoading = false
        guard error == nil, let ad = ad else {
          self.retryAttempt += 1
          guard self.retryAttempt == 1 else {
            return
          }
          let delaySec = 10.0
          print("InterstitialAd: did fail to load. Reload after \(delaySec)s! (\(String(describing: error)))")
          DispatchQueue.global().asyncAfter(deadline: .now() + delaySec, execute: self.load)
          return
        }
        print("InterstitialAd: did load!")
        self.retryAttempt = 0
        ad.fullScreenContentDelegate = self
        self.interstitialAd = ad
      }
    }
  }
  
  func isExist() -> Bool {
    return interstitialAd != nil
  }
  
  func isReady() -> Bool {
    if interstitialAd == nil, retryAttempt >= 2 {
      load()
    }
    return isExist() && wasLoadTimeLessThanNHoursAgo()
  }
  
  func show(willPresent: Handler?,
            willDismiss: Handler?,
            didDismiss: Handler?,
            didFail: Handler?
  ) {
    guard isReady() else {
      print("InterstitialAd: display failure - not ready to show!")
      return
    }
    guard !presentState else {
      print("InterstitialAd: display failure - ads are being displayed!")
      return
    }
    guard let topViewController = UIApplication.topStackViewController() else {
      print("InterstitialAd: display failure - can't find RootViewController!")
      return
    }
    print("InterstitialAd: requested to show!")
    self.willPresent = willPresent
    self.willDismiss = willDismiss
    self.didDismiss = didDismiss
    self.didFail = didFail
    interstitialAd?.present(fromRootViewController: topViewController)
  }
}

extension InterstitialAd: GADFullScreenContentDelegate {
  func ad(_ ad: GADFullScreenPresentingAd,
          didFailToPresentFullScreenContentWithError error: Error
  ) {
    print("InterstitialAd: did fail to show content!")
    didFail?()
    self.interstitialAd = nil
    load()
  }
  
  func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
    print("InterstitialAd: will display!")
    self.presentState = true
    willPresent?()
  }
  
  func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
    print("InterstitialAd: will hide!")
    willDismiss?()
  }
  
  func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
    print("InterstitialAd: did hide!")
    didDismiss?()
    self.interstitialAd = nil
    self.presentState = false
    if !isOnceUsed {
      load()
    }
    self.lastTimeDisplay = Date()
  }
}

extension InterstitialAd {
  private func wasLoadTimeLessThanNHoursAgo() -> Bool {
    let now = Date()
    let timeIntervalBetweenNowAndLoadTime = now.timeIntervalSince(lastTimeDisplay)
    return timeIntervalBetweenNowAndLoadTime >= timeBetween
  }
}
