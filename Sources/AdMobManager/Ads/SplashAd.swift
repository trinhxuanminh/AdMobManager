//
//  SplashAd.swift
//  AdMobManager
//
//  Created by Trịnh Xuân Minh on 25/03/2022.
//

import UIKit
import GoogleMobileAds

class SplashAd: NSObject, OnceAdProtocol {

  private var adUnitID: String?
  private var adReloadTime = 1.0
  private var presentState = false
  private var splashAd: GADInterstitialAd?
  private var stopLoadingState = false
  private var isLoading = false
  private var willPresent: (() -> Void)?
  private var willDismiss: (() -> Void)?
  private var didDismiss: (() -> Void)?
  private var loadRequestWorkItem: DispatchWorkItem?

  func setAdUnitID(_ adUnitID: String) {
    self.adUnitID = adUnitID
  }

  func setAdReloadTime(_ adReloadTime: Double) {
    self.adReloadTime = adReloadTime
  }

  func isPresent() -> Bool {
    return presentState
  }

  func stopLoading() {
    stopLoadingState = true
  }

  func load() {
    guard !stopLoadingState else {
      return
    }

    guard !isLoading else {
      return
    }

    guard !isExist() else {
      return
    }

    if #available(iOS 12.0, *), !NetworkMonitor.shared.isConnected() {
      print("Not connected!")
      request()
      return
    }

    guard let adUnitID = adUnitID else {
      print("No SplashAd ID!")
      return
    }

    isLoading = true

    let request = GADRequest()
    GADInterstitialAd.load(
      withAdUnitID: adUnitID,
      request: request
    ) { [weak self] (ad, error) in
      guard let self = self else {
        return
      }
      self.isLoading = false
      guard error == nil else {
        print("SplashAd download error, trying again!")
        return
      }
      self.splashAd = ad
      self.splashAd?.fullScreenContentDelegate = self
    }
  }

  func isExist() -> Bool {
    return splashAd != nil
  }

  func isReady() -> Bool {
    return isExist()
  }

  func show(
    willPresent: (() -> Void)?,
    willDismiss: (() -> Void)?,
    didDismiss: (() -> Void)?
  ) {
    guard isReady() else {
      print("SplashAd are not ready to show!")
      return
    }
    guard let topViewController = UIApplication.topStackViewController() else {
      print("Can't find RootViewController!")
      return
    }
    self.willPresent = willPresent
    self.willDismiss = willDismiss
    self.didDismiss = didDismiss
    splashAd?.present(fromRootViewController: topViewController)
  }
}

extension SplashAd: GADFullScreenContentDelegate {
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
    presentState = false
    didDismiss?()
  }
}

extension SplashAd {
  private func request() {
    DispatchQueue.global().asyncAfter(
      deadline: .now() + .milliseconds(Int(adReloadTime * 1000)),
      execute: load)
  }
}
