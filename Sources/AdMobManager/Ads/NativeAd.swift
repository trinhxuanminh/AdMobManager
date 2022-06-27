//
//  NativeAd.swift
//  AdMobManager
//
//  Created by Trịnh Xuân Minh on 25/03/2022.
//

import UIKit
import GoogleMobileAds

class NativeAd: NSObject {

  private var adUnitID: String?
  private var nativeAd: GADNativeAd?
  private var adLoader: GADAdLoader!
  private var configData: ((Int) -> Void)?
  private var didAddReloadingAd = false
  private var isLoading = false
  private var index: Int?

  override init() {
    super.init()
    guard !didAddReloadingAd else {
      return
    }
    didAddReloadingAd = true
    adUnitID = AdMobManager.shared.getNativeID()
    request()
  }

  func ad() -> GADNativeAd? {
    return nativeAd
  }

  func setConfigData(index: Int, execute work: ((Int) -> Void)? = nil) {
    self.index = index
    self.configData = work
  }

  private func load() {
    guard !isLoading else {
      return
    }

    guard !isExist() else {
      return
    }

    guard let adUnitID = adUnitID else {
      print("No NativeAd ID!")
      return
    }

    if #available(iOS 12.0, *), !NetworkMonitor.shared.isConnected() {
      print("Not connected!")
      request()
      return
    }

    guard let rootViewController = UIApplication.topStackViewController() else {
      print("Can't find RootViewController!")
      return
    }

    isLoading = true

    adLoader = GADAdLoader(
      adUnitID: adUnitID,
      rootViewController: rootViewController,
      adTypes: [.native],
      options: nil)
    adLoader.delegate = self
    adLoader.load(GADRequest())
  }

  private func request() {
    let adReloadTime = AdMobManager.shared.getAdReloadTime()
    DispatchQueue.main.asyncAfter(
      deadline: .now() + .milliseconds(Int(adReloadTime * 1000)),
      execute: load)
  }

  private func isExist() -> Bool {
    return nativeAd != nil
  }
}

extension NativeAd: GADNativeAdLoaderDelegate {
  func adLoader(_ adLoader: GADAdLoader,
                didFailToReceiveAdWithError error: Error) {
    print("NativeAd download error, trying again!")
    isLoading = false
  }

  func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
    self.nativeAd = nativeAd
    DispatchQueue.main.async { [weak self] in
      guard
        let self = self,
        let configData = self.configData,
        let index = self.index else {
        return
      }
      configData(index)
    }
  }
}
