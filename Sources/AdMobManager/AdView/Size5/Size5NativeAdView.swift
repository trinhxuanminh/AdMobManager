//
//  Size5NativeAdView.swift
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
/// - Warning: NativeAd will not be displayed without adding ID.
@IBDesignable public class Size5NativeAdView: BaseView, GADVideoControllerDelegate {
  @IBOutlet var contentView: UIView!
  @IBOutlet weak var callToActionButton: UIButton!
  @IBOutlet weak var bodyLabel: UILabel!
  @IBOutlet weak var advertiserLabel: UILabel!
  @IBOutlet weak var headlineLabel: UILabel!
  @IBOutlet weak var adLabel: UILabel!
  @IBOutlet weak var nativeAdView: GADNativeAdView!
  @IBOutlet weak var mediaView: GADMediaView!
  @IBOutlet weak var iconImageView: UIImageView!
  @IBOutlet weak var priceLabel: UILabel!
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
  
  override func addComponents() {
    Bundle.module.loadNibNamed(String(describing: Size5NativeAdView.self),
                               owner: self,
                               options: nil)
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
    nativeAdView.layer.cornerRadius = 8.0
    nativeAdView.layer.borderWidth = 0.5
    
    iconImageView.clipsToBounds = true
    
    callToActionButton.layer.cornerRadius = 8.0
    callToActionButton.clipsToBounds = true
    
    adLabel.layer.cornerRadius = 4.0
    adLabel.clipsToBounds = true
    adLabel.layer.borderWidth = 1.0
  }
  
  override func setColor() {
    nativeAdView.layer.borderColor = UIColor.white.cgColor
    
    changeLoading(color: UIColor.white)
    
    iconImageView.backgroundColor = UIColor.gray
    
    adLabel.backgroundColor = .clear
    adLabel.textColor = UIColor.white
    adLabel.layer.borderColor = UIColor.white.cgColor
    
    headlineLabel.textColor = UIColor.white
    
    advertiserLabel.textColor = UIColor.white
    
    bodyLabel.textColor = UIColor.white
    
    priceLabel.textColor = UIColor.white
    
    callToActionButton.setTitleColor(UIColor.black, for: .normal)
    callToActionButton.backgroundColor = UIColor(rgb: 0x90EBFF)
  }
  
  /// This function returns the minimum recommended height.
  public class func adHeightMinimum(width: CGFloat) -> CGFloat {
    let mediaHeight = (width - 20) / 16 * 9
    return (mediaHeight < 120 ? 120 : mediaHeight) + 173
  }
  
  public func register(id: String) {
    startAnimation()
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
  
  public func changeColor(
    border: UIColor? = nil,
    title: UIColor? = nil,
    advertiser: UIColor? = nil,
    price: UIColor? = nil,
    ad: UIColor? = nil,
    adBackground: UIColor? = nil,
    body: UIColor? = nil,
    mediaBackground: UIColor? = nil,
    callToAction: UIColor? = nil,
    callToActionBackground: UIColor? = nil
  ) {
    if let border = border {
      nativeAdView.layer.borderColor = border.cgColor
    }
    if let title = title {
      headlineLabel.textColor = title
    }
    if let advertiser = advertiser {
      advertiserLabel.textColor = advertiser
    }
    if let price = price {
      priceLabel.textColor = price
    }
    if let ad = ad {
      adLabel.textColor = ad
      adLabel.layer.borderColor = ad.cgColor
    }
    if let adBackground = adBackground {
      adLabel.backgroundColor = adBackground
    }
    if let body = body {
      bodyLabel.textColor = body
    }
    if let mediaBackground = mediaBackground {
      mediaView.backgroundColor = mediaBackground
    }
    if let callToAction = callToAction {
      callToActionButton.setTitleColor(callToAction, for: .normal)
    }
    if let callToActionBackground = callToActionBackground {
      callToActionButton.backgroundColor = callToActionBackground
    }
  }
  
  public func changeFont(
    title: UIFont? = nil,
    advertiser: UIFont? = nil,
    price: UIFont? = nil,
    ad: UIFont? = nil,
    body: UIFont? = nil,
    callToAction: UIFont? = nil
  ) {
    if let title = title {
      headlineLabel.font = title
    }
    if let advertiser = advertiser {
      advertiserLabel.font = advertiser
    }
    if let price = price {
      priceLabel.font = price
    }
    if let ad = ad {
      adLabel.font = ad
    }
    if let body = body {
      bodyLabel.font = body
    }
    if let callToAction = callToAction {
      callToActionButton.titleLabel?.font = callToAction
    }
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

extension Size5NativeAdView {
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
    
    (nativeAdView.priceView as? UILabel)?.text = nativeAd.price
    nativeAdView.priceView?.isHidden = nativeAd.price == nil
  }
}
