//
//  AdMobManager.swift
//  AdMobManager
//
//  Created by Trịnh Xuân Minh on 25/03/2022.
//

import UIKit
import GoogleMobileAds
import Foundation

/// An ad management structure. It supports setting InterstitialAd, RewardedAd, RewardedInterstitialAd, AppOpenAd, NativeAd, BannerAd.
/// ```
/// import AdMobManager
/// ```
/// - Warning: Available for Swift 5.3, Xcode 12.5 (macOS Big Sur). Support from iOS 10.0 or newer.
public struct AdMobManager {
  public static var shared = AdMobManager()
  
  public enum AdType: Int {
    case interstitial
    case rewarded
    case appOpen
    case rewardedInterstitial
    
    func createAd() -> AdProtocol {
      switch self {
      case .interstitial:
        return InterstitialAd()
      case .rewarded:
        return RewardedAd()
      case .appOpen:
        return AppOpenAd()
      case .rewardedInterstitial:
        return RewardedInterstitialAd()
      }
    }
  }
  
  private var listAds: [String: AdProtocol] = [:]
  
  public mutating func register(key: String, type: AdType, id: String, isOnceUsed: Bool = false) {
    guard listAds[key] == nil else {
      print("Key already exists!")
      return
    }
    let ad = type.createAd()
    ad.setAdUnitID(id, isOnceUsed: isOnceUsed)
    self.listAds[key] = ad
  }
  
  public func isReady(key: String) -> Bool? {
    guard let ad = listAds[key] else {
      print("Ads do not exist!")
      return nil
    }
    return ad.isReady()
  }
  
  public func show(
    key: String,
    willPresent: Handler? = nil,
    willDismiss: Handler? = nil,
    didDismiss: Handler? = nil,
    didFail: Handler? = nil
  ) {
    guard let ad = listAds[key] else {
      print("Ads do not exist!")
      return
    }
    guard !checkIsPresent() else {
      print("Ads display failure - other ads is showing!")
      return
    }
    ad.show(
      willPresent: willPresent,
      willDismiss: willDismiss,
      didDismiss: didDismiss,
      didFail: didFail)
  }
  
  public func setTimeBetween(key: String, time: Double) {
    guard let ad = listAds[key] else {
      print("Ads do not exist!")
      return
    }
    ad.setTimeBetween(time)
  }
}

extension AdMobManager {
  private func checkIsPresent() -> Bool {
    for ad in listAds {
      if ad.value.isPresent() {
        return true
      }
    }
    return false
  }
}
