//
//  NativeAdvancedAdView.swift
//  AdMobManager
//
//  Created by Trịnh Xuân Minh on 27/03/2022.
//

import UIKit
import GoogleMobileAds

/// This class returns a UIView displaying NativeAd.
/// ```
/// import AdMobManager
/// ```
/// Can be instantiated programmatically or Interface Builder. Use as UIView. Ad display is automatic.
/// Minimum height is **400**
/// - Warning: Native Ad will not be displayed without adding ID.
@IBDesignable public class NativeAdvancedAdView: BaseView, GADVideoControllerDelegate {

  /// This constant returns the minimum recommended height for NativeAdvancedAdView.
  public static let adHeightMinimum: CGFloat = 400

  @IBOutlet var contentView: UIView!
  @IBOutlet weak var callToActionButton: UIButton!
  @IBOutlet weak var storeLabel: UILabel!
  @IBOutlet weak var priceLabel: UILabel!
  @IBOutlet weak var bodyLabel: UILabel!
  @IBOutlet weak var advertiserLabel: UILabel!
  @IBOutlet weak var headlineLabel: UILabel!
  @IBOutlet weak var adLabel: UILabel!
  @IBOutlet weak var nativeAdView: GADNativeAdView! {
    didSet {
      nativeAdView.layer.borderWidth = 1.0
    }
  }

  private var listAd: [NativeAd?] = [NativeAd()]

  public override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    setAd()
  }

  public override init(frame: CGRect) {
    super.init(frame: frame)
    setAd()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }

  public override func removeFromSuperview() {
    for index in 0..<listAd.count {
      listAd[index] = nil
    }
    super.removeFromSuperview()
  }

  override func setColor() {
    callToActionButton.setTitleColor(UIColor(rgb: 0x87A605), for: .normal)
    storeLabel.textColor = UIColor(rgb: 0x000000)
    priceLabel.textColor = UIColor(rgb: 0x000000)
    bodyLabel.textColor = UIColor(rgb: 0x000000)
    advertiserLabel.textColor = UIColor(rgb: 0x000000, alpha: 0.6)
    headlineLabel.textColor = UIColor(rgb: 0x000000)
    adLabel.textColor = UIColor(rgb: 0x000000)
    adLabel.backgroundColor = UIColor(rgb: 0xFFB500)
    nativeAdView.layer.borderColor = UIColor(rgb: 0x87A605).cgColor
  }

  override func addComponents() {
    Bundle.module.loadNibNamed(NativeAdvancedAdView.className, owner: self, options: nil)
    addSubview(contentView)
  }

  override func setProperties() {
    contentView.frame = bounds
    contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
  }

  /// This function helps to change the ads in the cell.
  /// - Parameter index: Index of ads to show in the list.
  public func setAd(index: Int = 0) {
    guard index >= 0 else {
      return
    }
    if index >= listAd.count {
      for _ in listAd.count..<index {
        listAd.append(nil)
      }
      listAd.append(NativeAd())
    } else if listAd[index] == nil {
      listAd[index] = NativeAd()
    }
    config_Data(ad: listAd[index]?.ad())
    listAd[index]?.setConfigData({ [weak self] in
      guard let self = self else {
        return
      }
      self.config_Data(ad: self.listAd[index]?.ad())
    })
  }
}

extension NativeAdvancedAdView {
  func config_Data(ad: GADNativeAd?) {
    guard let nativeAd = ad else {
      nativeAdView?.isHidden = true
      return
    }

    nativeAdView?.isHidden = false
    nativeAdView?.nativeAd = nativeAd

    (nativeAdView?.headlineView as? UILabel)?.text = nativeAd.headline
    nativeAdView?.mediaView?.mediaContent = nativeAd.mediaContent

    let mediaContent = nativeAd.mediaContent
    if mediaContent.hasVideoContent {
      mediaContent.videoController.delegate = self
    }

    (nativeAdView?.bodyView as? UILabel)?.text = nativeAd.body
    nativeAdView?.bodyView?.isHidden = nativeAd.body == nil

    (nativeAdView?.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
    nativeAdView?.callToActionView?.isHidden = nativeAd.callToAction == nil

    (nativeAdView?.iconView as? UIImageView)?.image = nativeAd.icon?.image
    nativeAdView?.iconView?.isHidden = nativeAd.icon == nil

    (nativeAdView?.starRatingView as? UIImageView)?.image = imageOfStars(from: nativeAd.starRating)
    nativeAdView?.starRatingView?.isHidden = nativeAd.starRating == nil

    (nativeAdView?.storeView as? UILabel)?.text = nativeAd.store
    nativeAdView?.storeView?.isHidden = nativeAd.store == nil

    (nativeAdView?.priceView as? UILabel)?.text = nativeAd.price
    nativeAdView?.priceView?.isHidden = nativeAd.price == nil

    (nativeAdView?.advertiserView as? UILabel)?.text = nativeAd.advertiser
    nativeAdView?.advertiserView?.isHidden = nativeAd.advertiser == nil

    nativeAdView?.callToActionView?.isUserInteractionEnabled = false
  }

  func imageOfStars(from starRating: NSDecimalNumber?) -> UIImage? {
    guard let rating = starRating?.doubleValue else {
      return nil
    }

    var imageName: String?
    switch true {
    case rating >= 5.0:
      imageName = Icon.stars_5
    case rating >= 4.5:
      imageName = Icon.stars_4_5
    case rating >= 4.0:
      imageName = Icon.stars_4
    case rating >= 3.5:
      imageName = Icon.stars_3_5
    default:
      break
    }

    if let imageName = imageName, let image = UIImage(named: imageName, in: Bundle.module, compatibleWith: nil) {
      return image
    } else {
      return nil
    }
  }
}
