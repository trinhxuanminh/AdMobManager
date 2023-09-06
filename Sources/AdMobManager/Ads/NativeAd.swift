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
  private var rootViewController: UIViewController?
  private var adUnitID: String?
  private var isLoading = false
  private var isFullScreen = false
  private var binding: Handler?
  
  func config(ad: Native, rootViewController: UIViewController?) {
    self.rootViewController = rootViewController
    guard ad.status else {
      return
    }
    guard adUnitID == nil else {
      return
    }
    self.adUnitID = ad.id
    if let isFullScreen = ad.isFullScreen {
      self.isFullScreen = isFullScreen
    }
    self.load()
  }
  
  func getAd() -> GADNativeAd? {
    if nativeAd == nil {
      load()
    }
    return nativeAd
  }
  
  func setBinding(_ binding: Handler?) {
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
      print("AdMobManager: NativeAd failed to load - not initialized yet! Please install ID.")
      return
    }
    
    DispatchQueue.main.async { [weak self] in
      guard let self = self else {
        return
      }
      
      self.isLoading = true
      print("AdMobManager: NativeAd start load!")
      
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
  }
  
  private func isExist() -> Bool {
    return nativeAd != nil
  }
}

extension NativeAd: GADNativeAdLoaderDelegate {
  func adLoader(_ adLoader: GADAdLoader,
                didFailToReceiveAdWithError error: Error) {
    self.isLoading = false
  }
  
  func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
    print("AdMobManager: NativeAd did load!")
    self.isLoading = false
    self.nativeAd = nativeAd
    binding?()
  }
}
