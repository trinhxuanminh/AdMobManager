//
//  BannerAdView.swift
//  AdMobManager
//
//  Created by Trịnh Xuân Minh on 25/03/2022.
//

import UIKit
import GoogleMobileAds
import SkeletonView
import SnapKit

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
    return bannerView
  }()

  private var adUnitID: String?
  private var isLoading = false
  private var isExist = false
  private var didFirstLoadAd = false
  private var retryAttempt = 0.0
  private var baseColor = UIColor(rgb: 0x808080)
  private var secondaryColor = UIColor(rgb: 0xFFFFFF)

  public override func draw(_ rect: CGRect) {
    super.draw(rect)
    guard !didFirstLoadAd else {
      return
    }
    didFirstLoadAd = true
    adUnitID = AdMobManager.shared.getBannerID()
    load()
  }

  public override func removeFromSuperview() {
    bannerAdView = nil
    super.removeFromSuperview()
  }

  override func addComponents() {
    addSubview(bannerAdView)
  }

  override func setConstraints() {
    bannerAdView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }

  override func setProperties() {
    isSkeletonable = true
    showAnimatedGradientSkeleton(
      usingGradient: SkeletonGradient(
        baseColor: baseColor,
        secondaryColor: secondaryColor))
  }

  /// Change the color of animated.
  /// - Parameter base: Basic background color. Default is **gray**.
  /// - Parameter secondary: Animated colors. Default is **white**.
  public func setAnimatedColor(base: UIColor? = nil, secondary: UIColor? = nil) {
    if let secondary = secondary {
      self.secondaryColor = secondary
    }
    if let base = base {
      self.baseColor = base
    }
    updateAnimatedGradientSkeleton(
      usingGradient: SkeletonGradient(
        baseColor: baseColor,
        secondaryColor: secondaryColor))
  }

  private func load() {
    guard !isLoading else {
      return
    }

    guard !isExist else {
      return
    }

    guard let adUnitID = adUnitID else {
      print("BannerAd: failed to load - not initialized yet! Please install ID.")
      return
    }

    guard let rootViewController = UIApplication.topStackViewController() else {
      print("BannerAd: display failure - can't find RootViewController!")
      return
    }

    isLoading = true
    print("BannerAd: start load!")
    bannerAdView?.adUnitID = adUnitID
    bannerAdView?.delegate = self
    bannerAdView?.rootViewController = rootViewController
    bannerAdView?.load(GADRequest())
  }
}

extension BannerAdView: GADBannerViewDelegate {
  public func bannerView(_ bannerView: GADBannerView,
                         didFailToReceiveAdWithError error: Error
  ) {
    isLoading = false
    self.retryAttempt += 1
    let delaySec = pow(2.0, min(5.0, retryAttempt))
    print("BannerAd: did fail to load. Reload after \(delaySec)s! (\(error))")
    DispatchQueue.global().asyncAfter(deadline: .now() + delaySec, execute: load)
  }

  public func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
    print("BannerAd: did load!")
    self.retryAttempt = 0
    isExist = true
    hideSkeleton(reloadDataAfter: true)
  }
}
