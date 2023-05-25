//
//  Size12NativeAdView.swift
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
@IBDesignable public class Size12NativeAdView: BaseView, GADVideoControllerDelegate {
  @IBOutlet var contentView: UIView!
  @IBOutlet weak var callToActionButton: UIButton!
  @IBOutlet weak var headlineLabel: UILabel!
  @IBOutlet weak var adLabel: UILabel!
  @IBOutlet weak var adBackgroundView: UIView!
  @IBOutlet weak var nativeAdView: GADNativeAdView!
  @IBOutlet weak var iconImageView: UIImageView!
  @IBOutlet weak var starImageView: UIImageView!
  private lazy var loadingView: NVActivityIndicatorView = {
    let loadingView = NVActivityIndicatorView(frame: .zero)
    loadingView.type = .ballPulse
    loadingView.padding = 30.0
    return loadingView
  }()
  
  private var nativeAd: NativeAd?
  private var didStartAnimation = false
  
  public override func removeFromSuperview() {
    self.nativeAd = nil
    super.removeFromSuperview()
  }
  
  public override func draw(_ rect: CGRect) {
    super.draw(rect)
    guard !didStartAnimation else {
      return
    }
    self.didStartAnimation = true
    startAnimation()
  }
  
  override func addComponents() {
    Bundle.module.loadNibNamed(String(describing: Size12NativeAdView.self),
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
    
    adBackgroundView.layer.cornerRadius = 20.0
    adBackgroundView.layer.maskedCorners = [.layerMaxXMinYCorner]
    
    iconImageView.clipsToBounds = true
    iconImageView.layer.cornerRadius = 10.0
    
    callToActionButton.layer.cornerRadius = 5.0
    callToActionButton.clipsToBounds = true
  }
  
  override func setColor() {
    nativeAdView.layer.borderColor = UIColor.white.cgColor
    
    changeLoading(color: UIColor.white)
    
    iconImageView.backgroundColor = UIColor.gray
    
    adBackgroundView.backgroundColor = UIColor.white
    adLabel.textColor = UIColor.black
    
    headlineLabel.textColor = UIColor.white
    
    callToActionButton.setTitleColor(UIColor.black, for: .normal)
    callToActionButton.backgroundColor = UIColor(rgb: 0x90EBFF)
  }
  
  /// This function returns the minimum recommended height.
  public class func adHeight() -> CGFloat {
    return 62.0
  }
  
  public func register(id: String) {
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
    ad: UIColor? = nil,
    adBackground: UIColor? = nil,
    callToAction: UIColor? = nil,
    callToActionBackground: UIColor? = nil
  ) {
    if let border = border {
      nativeAdView.layer.borderColor = border.cgColor
    }
    if let title = title {
      headlineLabel.textColor = title
    }
    if let ad = ad {
      adLabel.textColor = ad
    }
    if let adBackground = adBackground {
      adBackgroundView.backgroundColor = adBackground
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
    ad: UIFont? = nil,
    callToAction: UIFont? = nil
  ) {
    if let title = title {
      headlineLabel.font = title
    }
    if let ad = ad {
      adLabel.font = ad
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

extension Size12NativeAdView {
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
    
    (nativeAdView.bodyView as? UILabel)?.text = nativeAd.body
    nativeAdView.bodyView?.isHidden = nativeAd.body == nil
    
    (nativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
    nativeAdView.callToActionView?.isUserInteractionEnabled = false
    
    (nativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image
    
    starImageView.image = imageOfStars(from: nativeAd.starRating)
    starImageView.isHidden = nativeAd.starRating == nil
  }
  
  private func imageOfStars(from starRating: NSDecimalNumber?) -> UIImage? {
    guard let rating = starRating?.doubleValue else {
      return nil
    }
    guard let image = UIImage(named: "\(Int(rating))_star", in: Bundle.module, compatibleWith: nil) else {
      return nil
    }
    return image
  }
}
