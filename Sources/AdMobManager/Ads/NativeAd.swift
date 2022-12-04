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
  private var isLoading = false
  private var isFullScreen = false
  private var retryAttempt = 0.0
  private var binding: (() -> Void)?
  
  func setAdUnitID(_ id: String, isFullScreen: Bool = false) {
    guard adUnitID == nil else {
      return
    }
    self.adUnitID = id
    self.isFullScreen = isFullScreen
    load()
  }
  
  func getAd() -> GADNativeAd? {
    return nativeAd
  }

  func setBinding(_ binding: (() -> Void)?) {
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
    
    var options: [GADAdLoaderOptions]? = nil
    if self.isFullScreen {
      let aspectRatioOption = GADNativeAdMediaAdLoaderOptions()
      aspectRatioOption.mediaAspectRatio = .portrait
      options = [aspectRatioOption]
    }
    let adLoader = GADAdLoader(
      adUnitID: adUnitID,
      rootViewController: rootViewController,
      adTypes: [.native],
      options: options)
    adLoader.delegate = self
    adLoader.load(GADRequest())
    self.adLoader = adLoader
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
    let delaySec = pow(2.0, min(5.0, retryAttempt))
    print("NativeAd: did fail to load. Reload after \(delaySec)s! (\(String(describing: error)))")
    DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + delaySec, execute: load)
  }

  func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
    print("NativeAd: did load!")
    self.nativeAd = nativeAd
    binding?()
  }
}
