//
//  NativeAd.swift
//  AdMobManager
//
//  Created by Trịnh Xuân Minh on 25/03/2022.
//

import UIKit
import GoogleMobileAds

class NativeAd: NSObject {
  private var nativeAd: GADNativeAd?
  private var adLoader: GADAdLoader?
  private var adUnitID: String?
  private var didAddID = false
  private var isLoading = false
  private var retryAttempt = 0.0
  private var index: Int?
  private var binding: ((Int) -> Void)?

  override init() {
    super.init()
    guard !didAddID else {
      return
    }
    self.didAddID = true
    self.adUnitID = AdMobManager.shared.getNativeID()
    load()
  }

  func ad() -> GADNativeAd? {
    return nativeAd
  }

  func setBinding(index: Int, binding: ((Int) -> Void)?) {
    self.index = index
    self.binding = binding
  }

  private func load() {
    guard !isLoading else {
      return
    }

    guard !isExist() else {
      return
    }

    guard let adUnitID = adUnitID else {
      print("NativeAd: failed to load - not initialized yet! Please install ID.")
      return
    }

    guard let rootViewController = UIApplication.topStackViewController() else {
      print("NativeAd: failed to load - can't find RootViewController!")
      return
    }

    self.isLoading = true
    print("NativeAd: start load!")
    self.adLoader = GADAdLoader(
      adUnitID: adUnitID,
      rootViewController: rootViewController,
      adTypes: [.native],
      options: nil)
    adLoader?.delegate = self
    adLoader?.load(GADRequest())
  }

  private func isExist() -> Bool {
    return nativeAd != nil
  }
}

extension NativeAd: GADNativeAdLoaderDelegate {
  func adLoader(_ adLoader: GADAdLoader,
                didFailToReceiveAdWithError error: Error) {
    self.isLoading = false
    self.retryAttempt += 1
    let delaySec = pow(2.0, min(5.0, self.retryAttempt))
    print("NativeAd: did fail to load. Reload after \(delaySec)s! (\(String(describing: error)))")
    DispatchQueue.global().asyncAfter(deadline: .now() + delaySec, execute: self.load)
  }

  func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
    self.nativeAd = nativeAd
    DispatchQueue.main.async { [weak self] in
      guard
        let self = self,
        let binding = self.binding,
        let index = self.index else {
        return
      }
      binding(index)
    }
  }
}
