//
//  RewardedAd.swift
//  
//
//  Created by Trịnh Xuân Minh on 02/12/2022.
//

import UIKit
import GoogleMobileAds

class RewardedAd: NSObject, AdProtocol {
  private var rewardedAd: GADRewardedAd?
  private var adUnitID: String?
  private var presentState = false
  private var isLoading = false
  private var retryAttempt = 0
  private var willPresent: Handler?
  private var willDismiss: Handler?
  private var didDismiss: Handler?
  private var didFail: Handler?
  
  func config(ad: Any) {
    guard let ad = ad as? Rewarded else {
      return
    }
    guard ad.status else {
      return
    }
    guard adUnitID == nil else {
      return
    }
    self.adUnitID = ad.id
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
      print("AdMobManager: RewardAd failed to load - not initialized yet! Please install ID.")
      return
    }
    
    DispatchQueue.main.async { [weak self] in
      guard let self = self else {
        return
      }
      
      self.isLoading = true
      print("AdMobManager: RewardAd start load!")
      
      let request = GADRequest()
      GADRewardedAd.load(
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
          print("AdMobManager: RewardAd did fail to load. Reload after \(delaySec)s! (\(String(describing: error)))")
          DispatchQueue.global().asyncAfter(deadline: .now() + delaySec, execute: self.load)
          return
        }
        print("AdMobManager: RewardAd did load!")
        self.retryAttempt = 0
        ad.fullScreenContentDelegate = self
        self.rewardedAd = ad
      }
    }
  }
  
  func isExist() -> Bool {
    return rewardedAd != nil
  }
  
  func isReady() -> Bool {
    if rewardedAd == nil, retryAttempt >= 2 {
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
    guard isExist() else {
      print("AdMobManager: RewardAd display failure - not ready to show!")
      return
    }
    guard !presentState else {
      print("AdMobManager: RewardAd display failure - ads are being displayed!")
      return
    }
    print("AdMobManager: RewardAd requested to show!")
    self.willPresent = willPresent
    self.willDismiss = willDismiss
    self.didDismiss = didDismiss
    self.didFail = didFail
    rewardedAd?.present(fromRootViewController: rootViewController, userDidEarnRewardHandler: {})
  }
}

extension RewardedAd: GADFullScreenContentDelegate {
  func ad(_ ad: GADFullScreenPresentingAd,
          didFailToPresentFullScreenContentWithError error: Error
  ) {
    print("AdMobManager: RewardAd did fail to show content!")
    didFail?()
    self.rewardedAd = nil
    load()
  }
  
  func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
    print("AdMobManager: RewardAd will display!")
    self.presentState = true
    willPresent?()
  }
  
  func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
    print("AdMobManager: RewardAd will hide!")
    willDismiss?()
  }
  
  func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
    print("AdMobManager: RewardAd did hide!")
    didDismiss?()
    self.rewardedAd = nil
    self.presentState = false
    load()
  }
}
