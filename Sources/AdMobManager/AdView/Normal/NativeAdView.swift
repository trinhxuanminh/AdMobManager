//
//  NativeAdView.swift
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
/// Minimum height is **100**
/// - Warning: Native Ad will not be displayed without adding ID.
@IBDesignable public class NativeAdView: BaseView {

  /// This constant returns the minimum recommended height for NativeAdView.
  public static let adHeightMinimum: CGFloat = 100

  @IBOutlet var contentView: UIView!
  @IBOutlet var nativeAdView: GADNativeAdView!
  @IBOutlet weak var headlineLabel: UILabel!
  @IBOutlet weak var adLabel: UILabel!
  @IBOutlet weak var advertiserLabel: UILabel!
  @IBOutlet weak var callToActionButton: UIButton!

  private var listAd: [NativeAd?] = [NativeAd()]

  public override func awakeFromNib() {
    super.awakeFromNib()
    setAd()
  }

  public override init(frame: CGRect) {
    super.init(frame: frame)
    setAd()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }

  override func setColor() {
    callToActionButton.setTitleColor(UIColor(rgb: 0xFFFFFF), for: .normal)
    callToActionButton.backgroundColor = UIColor(rgb: 0x87A605)
    advertiserLabel.textColor = UIColor(rgb: 0x000000, alpha: 0.6)
    headlineLabel.textColor = UIColor(rgb: 0x000000)
    adLabel.textColor = UIColor(rgb: 0x000000)
    adLabel.backgroundColor = UIColor(rgb: 0xFFB500)
    nativeAdView.layer.borderColor = UIColor(rgb: 0x87A605).cgColor
  }

  override func addComponents() {
    Bundle.module.loadNibNamed(nativeAdView.className, owner: self, options: nil)
    addSubview(contentView)
  }

  override func setProperties() {
    contentView.frame = bounds
    contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
  }


  public override func removeFromSuperview() {
    for index in 0..<listAd.count {
      self.listAd[index] = nil
    }
    super.removeFromSuperview()
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

extension NativeAdView {
  func config_Data(ad: GADNativeAd?) {
    guard let nativeAd = ad else {
      nativeAdView?.isHidden = true
      return
    }

    nativeAdView?.isHidden = false

    nativeAdView?.nativeAd = nativeAd

    (nativeAdView?.headlineView as? UILabel)?.text = nativeAd.headline

    (nativeAdView?.iconView as? UIImageView)?.image = nativeAd.icon?.image

    (nativeAdView?.advertiserView as? UILabel)?.text = nativeAd.advertiser
    nativeAdView?.advertiserView?.isHidden = nativeAd.advertiser == nil

    (nativeAdView?.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
    nativeAdView?.callToActionView?.isHidden = nativeAd.callToAction == nil

    // In order for the SDK to process touch events properly, user interaction should be disabled.
    nativeAdView?.callToActionView?.isUserInteractionEnabled = false
  }
}
