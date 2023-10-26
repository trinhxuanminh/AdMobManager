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
  private var start: Int?
  private var frequency: Int?
  private var countClick: Int = 0
  private var didShow: Handler?
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
    self.start = ad.start
    self.frequency = ad.frequency
    load()
  }
  
  func isPresent() -> Bool {
    return presentState
  }
  
  func show(rootViewController: UIViewController,
            didShow: Handler?,
            didFail: Handler?
  ) {
    guard isReady() else {
      print("AdMobManager: InterstitialAd display failure - not ready to show!")
      didFail?()
      return
    }
    guard !presentState else {
      print("AdMobManager: InterstitialAd display failure - ads are being displayed!")
      didFail?()
      return
    }
    print("AdMobManager: InterstitialAd requested to show!")
    self.didShow = didShow
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
    load()
  }
  
  func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
    print("AdMobManager: InterstitialAd will display!")
    self.presentState = true
  }
  
  func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
    print("AdMobManager: InterstitialAd did hide!")
    didShow?()
    self.interstitialAd = nil
    self.presentState = false
    load()
  }
}

extension InterstitialAd {
  private func isExist() -> Bool {
    return interstitialAd != nil
  }
  
  private func isReady() -> Bool {
    if !isExist(), retryAttempt >= 2 {
      load()
    }
    return checkFrequency() && isExist()
  }
  
  private func checkFrequency() -> Bool {
    guard
      let start = start,
      let frequency = frequency
    else {
      return true
    }
    self.countClick += 1
    if countClick < start {
      return false
    }
    let isShow = (countClick - start) % frequency == 0
    if isShow, !isExist() {
      self.countClick -= 1
    }
    return isShow
  }
  
  private func load() {
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
          guard self.retryAttempt == 1 else {
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
}
