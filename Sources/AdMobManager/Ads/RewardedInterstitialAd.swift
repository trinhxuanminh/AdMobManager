//
//  RewardedInterstitialAd.swift
//  
//
//  Created by Trịnh Xuân Minh on 05/12/2022.
//

import UIKit
import GoogleMobileAds

class RewardedInterstitialAd: NSObject, AdProtocol {
  private var rewardedInterstitialAd: GADRewardedInterstitialAd?
  private var adUnitID: String?
  private var presentState = false
  private var isLoading = false
  private var retryAttempt = 0
  private var didShow: Handler?
  private var didFail: Handler?
  
  func config(ad: Any) {
    guard let ad = ad as? RewardedInterstitial else {
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
  
  func show(rootViewController: UIViewController,
            didShow: Handler?,
            didFail: Handler?
  ) {
    guard isReady() else {
      print("AdMobManager: RewardedInterstitialAd display failure - not ready to show!")
      didFail?()
      return
    }
    guard !presentState else {
      print("AdMobManager: RewardedInterstitialAd display failure - ads are being displayed!")
      didFail?()
      return
    }
    print("AdMobManager: RewardedInterstitialAd requested to show!")
    self.didShow = didShow
    self.didFail = didFail
    rewardedInterstitialAd?.present(fromRootViewController: rootViewController, userDidEarnRewardHandler: { [weak self] in
      guard let self else {
        return
      }
      self.didShow?()
    })
  }
}

extension RewardedInterstitialAd: GADFullScreenContentDelegate {
  func ad(_ ad: GADFullScreenPresentingAd,
          didFailToPresentFullScreenContentWithError error: Error
  ) {
    print("AdMobManager: RewardedInterstitialAd did fail to show content!")
    didFail?()
    self.rewardedInterstitialAd = nil
    load()
  }
  
  func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
    print("AdMobManager: RewardedInterstitialAd will display!")
    self.presentState = true
  }
  
  func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
    print("AdMobManager: RewardedInterstitialAd did hide!")
    self.rewardedInterstitialAd = nil
    self.presentState = false
    load()
  }
}

extension RewardedInterstitialAd {
  private func isExist() -> Bool {
    return rewardedInterstitialAd != nil
  }
  
  private func isReady() -> Bool {
    if !isExist(), retryAttempt >= 2 {
      load()
    }
    return isExist()
  }
  
  private func load() {
    guard !isLoading else {
      return
    }
    
    guard !isExist() else {
      return
    }
    
    guard let adUnitID = adUnitID else {
      print("AdMobManager: RewardedInterstitialAd failed to load - not initialized yet! Please install ID.")
      return
    }
    
    DispatchQueue.main.async { [weak self] in
      guard let self = self else {
        return
      }
      
      self.isLoading = true
      print("AdMobManager: RewardedInterstitialAd start load!")
      
      let request = GADRequest()
      GADRewardedInterstitialAd.load(
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
          print("AdMobManager: RewardedInterstitialAd did fail to load. Reload after \(delaySec)s! (\(String(describing: error)))")
          DispatchQueue.global().asyncAfter(deadline: .now() + delaySec, execute: self.load)
          return
        }
        print("AdMobManager: RewardedInterstitialAd did load!")
        self.retryAttempt = 0
        ad.fullScreenContentDelegate = self
        self.rewardedInterstitialAd = ad
      }
    }
  }
}
