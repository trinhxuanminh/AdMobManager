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
  private var presentState = false
  private var isLoading = false
  private var retryAttempt = 0
  private var isOnceUsed = false
  private var willPresent: Handler?
  private var willDismiss: Handler?
  private var didDismiss: Handler?
  private var didFail: Handler?
  
  func config(ad: Any) {
    guard let ad = ad as? Interstitial else {
      return
    }
    guard ad.status else {
      return
    }
    guard adUnitID == nil else {
      return
    }
    self.adUnitID = ad.id
    self.isOnceUsed = ad.isOnceUsed
    load()
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
      print("AdMobManager: InterstitialAd failed to load - not initialized yet! Please install ID.")
      return
    }
    
    DispatchQueue.main.async { [weak self] in
      guard let self = self else {
        return
      }
      
      self.isLoading = true
      print("AdMobManager: InterstitialAd start load!")
      
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
          guard self.retryAttempt == 1, !isOnceUsed else {
            return
          }
          let delaySec = 5.0
          print("AdMobManager: InterstitialAd did fail to load. Reload after \(delaySec)s! (\(String(describing: error)))")
          DispatchQueue.global().asyncAfter(deadline: .now() + delaySec, execute: self.load)
          return
        }
        print("AdMobManager: InterstitialAd did load!")
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
    if !isOnceUsed, interstitialAd == nil, retryAttempt >= 2 {
      load()
    }
    return isExist()
  }
  
  func show(rootViewController: UIViewController,
            willPresent: Handler?,
            willDismiss: Handler?,
            didDismiss: Handler?,
            didFail: Handler?
  ) {
    guard isReady() else {
      print("AdMobManager: InterstitialAd display failure - not ready to show!")
      return
    }
    guard !presentState else {
      print("AdMobManager: InterstitialAd display failure - ads are being displayed!")
      return
    }
    print("AdMobManager: InterstitialAd requested to show!")
    self.willPresent = willPresent
    self.willDismiss = willDismiss
    self.didDismiss = didDismiss
    self.didFail = didFail
    interstitialAd?.present(fromRootViewController: rootViewController)
  }
}

extension InterstitialAd: GADFullScreenContentDelegate {
  func ad(_ ad: GADFullScreenPresentingAd,
          didFailToPresentFullScreenContentWithError error: Error
  ) {
    print("AdMobManager: InterstitialAd did fail to show content!")
    didFail?()
    self.interstitialAd = nil
    if !isOnceUsed {
      load()
    }
  }
  
  func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
    print("AdMobManager: InterstitialAd will display!")
    self.presentState = true
    willPresent?()
  }
  
  func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
    print("AdMobManager: InterstitialAd will hide!")
    willDismiss?()
  }
  
  func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
    print("AdMobManager: InterstitialAd did hide!")
    didDismiss?()
    self.interstitialAd = nil
    self.presentState = false
    if !isOnceUsed {
      load()
    }
  }
}

