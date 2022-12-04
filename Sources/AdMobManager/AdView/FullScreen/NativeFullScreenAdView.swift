//
//  NativeFullScreenAdView.swift
//  
//
//  Created by Trịnh Xuân Minh on 04/12/2022.
//

import UIKit
import GoogleMobileAds
import NVActivityIndicatorView
import SnapKit

@IBDesignable public class NativeFullScreenAdView: BaseView, GADVideoControllerDelegate {
  @IBOutlet var contentView: UIView!
  @IBOutlet weak var nativeAdView: GADNativeAdView!
  @IBOutlet weak var callToActionButton: UIButton!
  @IBOutlet weak var bodyLabel: UILabel!
  @IBOutlet weak var advertiserLabel: UILabel!
  @IBOutlet weak var headlineLabel: UILabel!
  @IBOutlet weak var adLabel: UILabel!
  @IBOutlet weak var iconImageView: UIImageView!
  @IBOutlet weak var mediaView: GADMediaView!
  private lazy var loadingView: NVActivityIndicatorView = {
    let loadingView = NVActivityIndicatorView(frame: .zero)
    loadingView.type = .ballPulse
    loadingView.padding = 30.0
    return loadingView
  }()
  
  private var nativeAd: NativeAd?
  
  public override func removeFromSuperview() {
    self.nativeAd = nil
    super.removeFromSuperview()
  }
  
  public override func draw(_ rect: CGRect) {
    super.draw(rect)
    startAnimation()
  }
  
  override func addComponents() {
    Bundle.module.loadNibNamed(String(describing: NativeFullScreenAdView.self), owner: self, options: nil)
    addSubview(contentView)
    addSubview(loadingView)
  }

  override func setConstraints() {
    contentView.frame = bounds
    contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    
    loadingView.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.width.height.equalTo(20)
    }
  }
  
  public func setID(_ id: String) {
    guard nativeAd == nil else {
      return
    }
    let nativeAd = NativeAd()
    nativeAd.setAdUnitID(id, isFullScreen: true)
    nativeAd.setBinding { [weak self] in
      guard let self = self else {
        return
      }
      self.binding(ad: nativeAd.getAd())
    }
    self.nativeAd = nativeAd
  }
}

extension NativeFullScreenAdView {
  private func startAnimation() {
    nativeAdView.isHidden = true
    loadingView.startAnimating()
  }
  
  private func stopAnimation() {
    nativeAdView.isHidden = false
    loadingView.stopAnimating()
  }
  
  private func binding(ad: GADNativeAd?) {
    guard let nativeAd = ad else {
      return
    }
    
    stopAnimation()

    nativeAdView.nativeAd = nativeAd

    (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline

    nativeAdView.mediaView?.mediaContent = nativeAd.mediaContent
    mediaView.isHidden = false
    let mediaContent = nativeAd.mediaContent
    if mediaContent.hasVideoContent {
      mediaContent.videoController.delegate = self
    }

    (nativeAdView.bodyView as? UILabel)?.text = nativeAd.body
    nativeAdView.bodyView?.isHidden = nativeAd.body == nil

    (nativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
    nativeAdView.callToActionView?.isUserInteractionEnabled = false

    (nativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image

    (nativeAdView.advertiserView as? UILabel)?.text = nativeAd.advertiser
    nativeAdView.advertiserView?.isHidden = nativeAd.advertiser == nil
  }
  
  private func changeLoadingColor(_ color: UIColor) {
    var isAnimating = false
    if loadingView.isAnimating {
      isAnimating = true
      loadingView.stopAnimating()
    }
    loadingView.color = color
    guard isAnimating else {
      return
    }
    loadingView.startAnimating()
  }
}
