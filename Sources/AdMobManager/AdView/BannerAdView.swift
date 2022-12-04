//
//  BannerAdView.swift
//  AdMobManager
//
//  Created by Trịnh Xuân Minh on 25/03/2022.
//

import UIKit
import GoogleMobileAds
import SnapKit
import NVActivityIndicatorView

/// This class returns a UIView displaying BannerAd.
/// ```
/// import AdMobManager
/// ```
/// Can be instantiated programmatically or Interface Builder. Use as UIView. Ad display is automatic.
/// - Warning: Ad will not be displayed without adding ID.
@IBDesignable public class BannerAdView: BaseView {
  private lazy var bannerAdView: GADBannerView! = {
    let bannerView = GADBannerView()
    return bannerView
  }()
  private lazy var loadingView: NVActivityIndicatorView = {
    let loadingView = NVActivityIndicatorView(frame: .zero)
    loadingView.type = .ballPulse
    loadingView.padding = 30.0
    loadingView.color = UIColor(rgb: 0xFFFFFF)
    return loadingView
  }()

  private var adUnitID: String?
  private var isLoading = false
  private var isExist = false
  private var didStartAnimation = false
  private var retryAttempt = 0.0

  public override func draw(_ rect: CGRect) {
    super.draw(rect)
    guard !didStartAnimation else {
      return
    }
    didStartAnimation = true
    startAnimation()
  }

  public override func removeFromSuperview() {
    self.bannerAdView = nil
    super.removeFromSuperview()
  }

  override func addComponents() {
    addSubview(bannerAdView)
    addSubview(loadingView)
  }

  override func setConstraints() {
    bannerAdView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    loadingView.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.width.height.equalTo(20)
    }
  }
  
  /// This function returns the minimum recommended height for BannerAdView.
  public class func adHeightMinimum() -> CGFloat {
    return 60.0
  }
  
  public func register(id: String) {
    guard adUnitID == nil else {
      return
    }
    self.adUnitID = id
    load()
  }
  
  public func changeLoading(type: NVActivityIndicatorType? = nil, color: UIColor? = nil) {
    var isAnimating = false
    if loadingView.isAnimating {
      isAnimating = true
      loadingView.stopAnimating()
    }
    if let type = type {
      loadingView.type = type
    }
    if let color = color {
      loadingView.color = color
    }
    guard isAnimating else {
      return
    }
    loadingView.startAnimating()
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
    stopAnimation()
  }
}

extension BannerAdView {
  private func startAnimation() {
    bannerAdView.isHidden = true
    loadingView.startAnimating()
  }
  
  private func stopAnimation() {
    bannerAdView.isHidden = false
    loadingView.stopAnimating()
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
