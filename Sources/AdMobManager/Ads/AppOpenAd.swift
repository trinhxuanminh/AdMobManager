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
      print("AppOpenAd: set time between failed - invalid time!")
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
      print("AppOpenAd: failed to load - not initialized yet! Please install ID.")
      return
    }
    
    self.isLoading = true
    print("AppOpenAd: start load!")
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
        let delaySec = pow(2.0, min(5.0, self.retryAttempt))
        print("AppOpenAd: did fail to load. Reload after \(delaySec)s! (\(String(describing: error)))")
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + delaySec, execute: self.load)
        return
      }
      print("AppOpenAd: did load!")
      self.retryAttempt = 0
      ad.fullScreenContentDelegate = self
      self.appOpenAd = ad
    }
  }
  
  func isExist() -> Bool {
    return appOpenAd != nil
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
      print("AppOpenAd: display failure - not ready to show!")
      return
    }
    guard !presentState else {
      print("AppOpenAd: display failure - ads are being displayed!")
      return
    }
    guard let topViewController = UIApplication.topStackViewController() else {
      print("AppOpenAd: display failure - can't find RootViewController!")
      return
    }
    print("AppOpenAd: requested to show!")
    self.willPresent = willPresent
    self.willDismiss = willDismiss
    self.didDismiss = didDismiss
    self.didFail = didFail
    appOpenAd?.present(fromRootViewController: topViewController)
  }
}

extension AppOpenAd: GADFullScreenContentDelegate {
  func ad(_ ad: GADFullScreenPresentingAd,
          didFailToPresentFullScreenContentWithError error: Error
  ) {
    print("AppOpenAd: did fail to show content!")
    didFail?()
    self.appOpenAd = nil
    load()
  }
  
  func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
    print("AppOpenAd: will display!")
    self.presentState = true
    willPresent?()
  }
  
  func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
    print("AppOpenAd: will hide!")
    willDismiss?()
  }
  
  func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
    print("AppOpenAd: did hide!")
    didDismiss?()
    self.appOpenAd = nil
    self.presentState = false
    load()
    self.lastTimeDisplay = Date()
  }
}

extension AppOpenAd {
  private func wasLoadTimeLessThanNHoursAgo() -> Bool {
    let now = Date()
    let timeIntervalBetweenNowAndLoadTime = now.timeIntervalSince(lastTimeDisplay)
    return timeIntervalBetweenNowAndLoadTime > timeBetween
  }
}
