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
  private weak var rootViewController: UIViewController?
  private var adUnitID: String?
  private var isFullScreen = false
  private var state: State = .wait
  private var didReceive: Handler?
  private var didError: Handler?
  
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
  
  func getState() -> State {
    return state
  }
  
  func getAd() -> GADNativeAd? {
    return nativeAd
  }
  
  func bind(didReceive: Handler?, didError: Handler?) {
    self.didReceive = didReceive
    self.didError = didError
  }
}

extension NativeAd: GADNativeAdLoaderDelegate {
  func adLoader(_ adLoader: GADAdLoader,
                didFailToReceiveAdWithError error: Error) {
    print("AdMobManager: NativeAd load fail - \(String(describing: error))!")
    self.state = .error
    didError?()
  }
  
  func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
    print("AdMobManager: NativeAd did load!")
    self.state = .receive
    self.nativeAd = nativeAd
    didReceive?()
    nativeAd.paidEventHandler = { [weak self] adValue in
      guard let self else {
        return
      }
//      
    }
  }
}

extension NativeAd {
  private func load() {
    guard state == .wait else {
      return
    }
    
    guard let adUnitID = adUnitID else {
      print("AdMobManager: NativeAd failed to load - not initialized yet! Please install ID.")
      return
    }
    
    print("AdMobManager: NativeAd start load!")
    self.state = .loading
    DispatchQueue.main.async { [weak self] in
      guard let self = self else {
        return
      }
      var options: [GADAdLoaderOptions]? = nil
      if self.isFullScreen {
        let aspectRatioOption = GADNativeAdMediaAdLoaderOptions()
        aspectRatioOption.mediaAspectRatio = .portrait
        options = [aspectRatioOption]
      }
      self.adLoader = GADAdLoader(
        adUnitID: adUnitID,
        rootViewController: rootViewController,
        adTypes: [.native],
        options: options)
      self.adLoader?.delegate = self
      self.adLoader?.load(GADRequest())
    }
  }
}
