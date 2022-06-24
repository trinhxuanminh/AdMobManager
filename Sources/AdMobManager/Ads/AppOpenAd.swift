//
//  AppOpenAd.swift
//  AdMobManager
//
//  Created by Trịnh Xuân Minh on 25/03/2022.
//

import UIKit
import GoogleMobileAds

class AppOpenAd: NSObject, ReuseAdProtocol {

  private var adUnitID: String?
  private var timeBetween = 5.0
  private var adReloadTime = 1.0
  private var presentState = false
  private var appOpenAd: GADAppOpenAd?
  private var loadTime = Date()
  private var isLoading = false
  private var willPresent: (() -> Void)?
  private var willDismiss: (() -> Void)?
  private var didDismiss: (() -> Void)?
  private var loadRequestWorkItem: DispatchWorkItem?

  func setAdUnitID(_ adUnitID: String) {
    self.adUnitID = adUnitID
  }

  func setTimeBetween(_ timeBetween: Double) {
    self.timeBetween = timeBetween
  }

  func setAdReloadTime(_ adReloadTime: Double) {
    self.adReloadTime = adReloadTime
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
      print("No AppOpenAd ID!")
      return
    }

    if #available(iOS 12.0, *), !NetworkMonitor.shared.isConnected() {
      print("Not connected!")
      request()
      return
    }

    isLoading = true

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
      guard error == nil else {
        print("AppOpenAd download error, trying again!")
        return
      }
      self.appOpenAd = ad
      self.appOpenAd?.fullScreenContentDelegate = self
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
            didDismiss: (() -> Void)?
  ) {
    guard isReady() else {
      print("AppOpenAd are not ready to show!")
      guard #available(iOS 12.0, *) else {
        load()
        return
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
    appOpenAd?.present(fromRootViewController: topViewController)
  }
}

extension AppOpenAd: GADFullScreenContentDelegate {
  func ad(_ ad: GADFullScreenPresentingAd,
          didFailToPresentFullScreenContentWithError error: Error
  ) {
    print("Ad did fail to present full screen content.")
    didDismiss?()
  }

  func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
    presentState = true
    willPresent?()
  }

  func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
    willDismiss?()
  }

  func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
    print("Ad did dismiss full screen content.")
    didDismiss?()
    appOpenAd = nil
    presentState = false
    load()
    loadTime = Date()
  }
}

extension AppOpenAd {
  private func request() {
    DispatchQueue.global().asyncAfter(
      deadline: .now() + .milliseconds(Int(adReloadTime * 1000)),
      execute: load)
  }

  private func wasLoadTimeLessThanNHoursAgo() -> Bool {
    let now = Date()
    let timeIntervalBetweenNowAndLoadTime = now.timeIntervalSince(loadTime)
    return timeIntervalBetweenNowAndLoadTime > timeBetween
  }
}
