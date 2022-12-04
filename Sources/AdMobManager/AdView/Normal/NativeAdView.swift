//
//  NativeAdView.swift
//  AdMobManager
//
//  Created by Trịnh Xuân Minh on 27/03/2022.
//

import UIKit
import GoogleMobileAds
import SnapKit
import NVActivityIndicatorView

/// This class returns a UIView displaying NativeAd.
/// ```
/// import AdMobManager
/// ```
/// Can be instantiated programmatically or Interface Builder. Use as UIView. Ad display is automatic.
/// Minimum height is **100**
/// - Warning: Native Ad will not be displayed without adding ID.
@IBDesignable public class NativeAdView: BaseView {
  @IBOutlet var contentView: UIView!
  @IBOutlet var nativeAdView: GADNativeAdView!
  @IBOutlet weak var headlineLabel: UILabel!
  @IBOutlet weak var adLabel: UILabel!
  @IBOutlet weak var advertiserLabel: UILabel!
  @IBOutlet weak var callToActionButton: UIButton!
  @IBOutlet weak var iconImageView: UIImageView!
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
    Bundle.module.loadNibNamed(String(describing: NativeAdView.self), owner: self, options: nil)
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
  
  override func setProperties() {
    callToActionButton.layer.cornerRadius = 4.0
    
    adLabel.layer.borderWidth = 1.0
    adLabel.layer.cornerRadius = 4.0
  }
  
  override func setColor() {
    iconImageView.backgroundColor = UIColor(rgb: 0xF2F2F7)
    
    adLabel.backgroundColor = UIColor(rgb: 0xFFFFFF)
    adLabel.textColor = UIColor(rgb: 0x456631)
    adLabel.layer.borderColor = UIColor(rgb: 0x456631).cgColor
    
    headlineLabel.textColor = UIColor(rgb: 0xFFFFFF)
    
    advertiserLabel.textColor = UIColor(rgb: 0xFFFFFF)
    
    callToActionButton.setTitleColor(UIColor(rgb: 0xFFFFFF), for: .normal)
    callToActionButton.backgroundColor = UIColor(rgb: 0x6399F0)
  }

  /// This function returns the minimum recommended height for NativeAdView.
  public class func adHeightMinimum() -> CGFloat {
    return 100.0
  }
  
  public func setID(_ id: String) {
    if let nativeAd = nativeAd {
      binding(ad: nativeAd.getAd())
      return
    }
    let nativeAd = NativeAd()
    nativeAd.setAdUnitID(id)
    nativeAd.setBinding { [weak self] in
      guard let self = self else {
        return
      }
      self.binding(ad: nativeAd.getAd())
    }
    self.nativeAd = nativeAd
  }
}

extension NativeAdView {
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
