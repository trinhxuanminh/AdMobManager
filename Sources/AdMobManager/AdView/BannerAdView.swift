//
//  BannerAdView.swift
//  AdMobManager
//
//  Created by Trịnh Xuân Minh on 25/03/2022.
//

import UIKit
import GoogleMobileAds

/// This class returns a UIView displaying BannerAd.
/// ```
/// import AdMobManager
/// ```
/// Can be instantiated programmatically or Interface Builder. Use as UIView. Ad display is automatic.
/// - Warning: Ad will not be displayed without adding ID.
@IBDesignable public class BannerAdView: BaseView {

  private lazy var bannerAdView: GADBannerView! = {
    let bannerView = GADBannerView()
    bannerView.translatesAutoresizingMaskIntoConstraints = false
    bannerView.isHidden = true
    return bannerView
  }()

  private var adUnitID: String?
  private var isLoading = false
  private var isExist = false
  private var didFirstLoadAd = false

  override func addComponents() {
    addSubview(bannerAdView)
  }

  override func setConstraints() {
    NSLayoutConstraint.activate([
      bannerAdView.bottomAnchor.constraint(equalTo: bottomAnchor),
      bannerAdView.leadingAnchor.constraint(equalTo: leadingAnchor),
      bannerAdView.trailingAnchor.constraint(equalTo: trailingAnchor),
      bannerAdView.topAnchor.constraint(equalTo: topAnchor)
    ])
  }

  public override func draw(_ rect: CGRect) {
    super.draw(rect)
    guard !didFirstLoadAd else {
      return
    }
    didFirstLoadAd = true
    adUnitID = AdMobManager.shared.getBannerID()
    request()
  }

  public override func removeFromSuperview() {
    bannerAdView = nil
    super.removeFromSuperview()
  }

  private func load() {
    guard !isLoading else {
      return
    }

    guard !isExist else {
      return
    }

    guard let adUnitID = adUnitID else {
      print("No BannerAd ID!")
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

    bannerAdView?.adUnitID = adUnitID
    bannerAdView?.delegate = self
    bannerAdView?.rootViewController = rootViewController
    bannerAdView?.load(GADRequest())
  }

  func request() {
    let adReloadTime = AdMobManager.shared.getAdReloadTime()
    DispatchQueue.main.asyncAfter(
      deadline: .now() + .milliseconds(Int(adReloadTime * 1000)),
      execute: load)
  }
}

extension BannerAdView: GADBannerViewDelegate {
  public func bannerView(_ bannerView: GADBannerView,
                         didFailToReceiveAdWithError error: Error
  ) {
    print("BannerAd download error, trying again!")
    isLoading = false
  }

  public func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
    isExist = true
    bannerAdView?.isHidden = false
  }
}
