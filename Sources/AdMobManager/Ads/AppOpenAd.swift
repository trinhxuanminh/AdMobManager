//
//  AppOpenAd.swift
//  AdMobManager
//
//  Created by Trịnh Xuân Minh on 25/03/2022.
//

import UIKit
import GoogleMobileAds

class AppOpenAd: NSObject, AdProtocol {
  private var appOpenAd: GADAppOpenAd?
  private var adUnitID: String?
  private var presentState = false
  private var isLoading = false
  private var retryAttempt = 0
  private var didFail: Handler?
  private var didEarnReward: Handler?
  private var didHide: Handler?
  
  func config(ad: Any) {
    guard let ad = ad as? AppOpen else {
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
            didFail: Handler?,
            didEarnReward: Handler?,
            didHide: Handler?
  ) {
    guard isReady() else {
      print("AdMobManager: AppOpenAd display failure - not ready to show!")
      didFail?()
      return
    }
    guard !presentState else {
      print("AdMobManager: AppOpenAd display failure - ads are being displayed!")
      didFail?()
      return
    }
    print("AdMobManager: AppOpenAd requested to show!")
    self.didFail = didFail
    self.didHide = didHide
    self.didEarnReward = didEarnReward
    appOpenAd?.present(fromRootViewController: rootViewController)
  }
}

extension AppOpenAd: GADFullScreenContentDelegate {
  func ad(_ ad: GADFullScreenPresentingAd,
          didFailToPresentFullScreenContentWithError error: Error
  ) {
    print("AdMobManager: AppOpenAd did fail to show content!")
    didFail?()
    self.appOpenAd = nil
    load()
  }
  
  func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
    print("AdMobManager: AppOpenAd will display!")
    self.presentState = true
  }
  
  func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
    print("AdMobManager: AppOpenAd did hide!")
    didHide?()
    self.appOpenAd = nil
    self.presentState = false
    load()
  }
}

extension AppOpenAd {
  private func isExist() -> Bool {
    return appOpenAd != nil
  }
  
  private func isReady() -> Bool {
    if !isExist(), retryAttempt >= 1 {
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
      print("AdMobManager: AppOpenAd failed to load - not initialized yet! Please install ID.")
      return
    }
    
    DispatchQueue.main.async { [weak self] in
      guard let self = self else {
        return
      }
      
      self.isLoading = true
      print("AdMobManager: AppOpenAd start load!")
      
      let request = GADRequest()
      GADAppOpenAd.load(
        withAdUnitID: adUnitID,
        request: request,
        orientation: UIInterfaceOrientation.portrait
      ) { [weak self] (ad, error) in
        guard let self = self else {
          return
        }
        self.isLoading = false
        guard error == nil, let ad = ad else {
          self.retryAttempt += 1
          return
        }
        print("AdMobManager: AppOpenAd did load!")
        self.retryAttempt = 0
        self.appOpenAd = ad
        self.appOpenAd?.fullScreenContentDelegate = self
      }
    }
  }
}
