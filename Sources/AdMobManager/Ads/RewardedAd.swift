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
  private var timeBetween = 10.0
  private var presentState = false
  private var lastTimeDisplay = Date()
  private var isLoading = false
  private var retryAttempt = 0.0
  private var willPresent: (() -> Void)?
  private var willDismiss: (() -> Void)?
  private var didDismiss: (() -> Void)?
  private var didFail: (() -> Void)?
  
  func setAdUnitID(_ id: String) {
    guard adUnitID == nil else {
      return
    }
    self.adUnitID = id
    load()
  }
  
  func setTimeBetween(_ timeBetween: Double) {
    guard timeBetween > 0.0 else {
      print("RewardAd: set time between failed - invalid time!")
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
      print("RewardAd: failed to load - not initialized yet! Please install ID.")
      return
    }
    
    self.isLoading = true
    print("RewardAd: start load!")
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
        let delaySec = pow(2.0, min(5.0, self.retryAttempt))
        print("RewardAd: did fail to load. Reload after \(delaySec)s! (\(String(describing: error)))")
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + delaySec, execute: self.load)
        return
      }
      print("RewardAd: did load!")
      self.retryAttempt = 0
      ad.fullScreenContentDelegate = self
      self.rewardedAd = ad
    }
  }
  
  func isExist() -> Bool {
    return rewardedAd != nil
  }
  
  func isReady() -> Bool {
    return isExist() && wasLoadTimeLessThanNHoursAgo()
  }
  
  func show(willPresent: (() -> Void)?,
            willDismiss: (() -> Void)?,
            didDismiss: (() -> Void)?,
            didFail: (() -> Void)?
  ) {
    guard isReady() else {
      print("RewardAd: display failure - not ready to show!")
      return
    }
    guard !presentState else {
      print("RewardAd: display failure - ads are being displayed!")
      return
    }
    guard let topViewController = UIApplication.topStackViewController() else {
      print("RewardAd: display failure - can't find RootViewController!")
      return
    }
    print("RewardAd: requested to show!")
    self.willPresent = willPresent
    self.willDismiss = willDismiss
    self.didDismiss = didDismiss
    self.didFail = didFail
    rewardedAd?.present(fromRootViewController: topViewController, userDidEarnRewardHandler: {})
  }
}

extension RewardedAd: GADFullScreenContentDelegate {
  func ad(_ ad: GADFullScreenPresentingAd,
          didFailToPresentFullScreenContentWithError error: Error
  ) {
    print("RewardAd: did fail to show content!")
    didFail?()
    self.rewardedAd = nil
    load()
  }
  
  func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
    print("RewardAd: will display!")
    self.presentState = true
    willPresent?()
  }
  
  func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
    print("RewardAd: will hide!")
    willDismiss?()
  }
  
  func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
    print("RewardAd: did hide!")
    didDismiss?()
    self.rewardedAd = nil
    self.presentState = false
    load()
    self.lastTimeDisplay = Date()
  }
}

extension RewardedAd {
  private func wasLoadTimeLessThanNHoursAgo() -> Bool {
    let now = Date()
    let timeIntervalBetweenNowAndLoadTime = now.timeIntervalSince(lastTimeDisplay)
    return timeIntervalBetweenNowAndLoadTime > timeBetween
  }
}
