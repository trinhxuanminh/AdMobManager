//
//  NativeAdView.swift
//  AdMobManager
//
//  Created by Trịnh Xuân Minh on 27/03/2022.
//

import UIKit
import GoogleMobileAds
import SkeletonView

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
  @IBOutlet weak var skeletonView: UIView!

  private var listAd: [NativeAd?] = [NativeAd()]
  private var indexState: Int!
  private var baseColor = UIColor(rgb: 0x808080)
  private var secondaryColor = UIColor(rgb: 0xFFFFFF)
  private var isLoading = false
  private var didFirstLoadAd = false

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
    callToActionButton.backgroundColor = UIColor(rgb: 0x87A605)
    setLightColor()
  }

  override func addComponents() {
    Bundle.module.loadNibNamed(NativeAdView.className, owner: self, options: nil)
    addSubview(contentView)
  }

  override func setProperties() {
    contentView.frame = bounds
    contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    backgroundColor = .red
    contentView.backgroundColor = .green
  }

  public override func removeFromSuperview() {
    for index in 0..<listAd.count {
      self.listAd[index] = nil
    }
    super.removeFromSuperview()
  }

  public override func draw(_ rect: CGRect) {
    super.draw(rect)
    guard isLoading else {
      return
    }
    startAnimation()
  }

  /// This function helps to change the ads in the cell.
  /// - Parameter index: Index of ads to show in the list.
  public func setAd(index: Int = 0) {
    guard index >= 0 else {
      return
    }
    indexState = index
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

  /// This function helps to adjust the color of the ad content.
  /// - Parameter style: Change the color of the labels according to the interface style. Default is **light**.
  public func setInterface(style: AdMobManager.Style) {
    switch style {
    case .light:
      setLightColor()
    case .dark:
      setDarkColor()
    }
  }

  /// This function helps to adjust the color of the ad content.
  /// - Parameter color: Change the background color of the buttons. Default is **#87A605**.
  public func setTheme(color: UIColor) {
    callToActionButton.backgroundColor = color
  }

  /// Change the color of animated.
  /// - Parameter base: Basic background color. Default is **gray**.
  /// - Parameter secondary: Animated colors. Default is **white**.
  public func setAnimatedColor(base: UIColor? = nil, secondary: UIColor? = nil) {
    if let secondary = secondary {
      secondaryColor = secondary
    }
    if let base = base {
      baseColor = base
    }
    guard isLoading else {
      return
    }
    skeletonView.updateAnimatedGradientSkeleton(
      usingGradient: SkeletonGradient(
        baseColor: baseColor,
        secondaryColor: secondaryColor))
  }
}

extension NativeAdView {
  private func config_Data(ad: GADNativeAd?) {
    guard let nativeAd = ad else {
      isLoading = true
//      guard didFirstLoadAd else {
//        return
//      }
      startAnimation()
      return
    }

    didFirstLoadAd = true

    if isLoading {
      isLoading = false
      skeletonView.hideSkeleton(reloadDataAfter: true)
    }

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

  private func setLightColor() {
    callToActionButton.setTitleColor(UIColor(rgb: 0xFFFFFF), for: .normal)
    advertiserLabel.textColor = UIColor(rgb: 0x000000, alpha: 0.5)
    headlineLabel.textColor = UIColor(rgb: 0x000000)
    adLabel.textColor = UIColor(rgb: 0x000000)
    adLabel.backgroundColor = UIColor(rgb: 0xFFB500)
  }

  private func setDarkColor() {
    callToActionButton.setTitleColor(UIColor(rgb: 0x000000), for: .normal)
    advertiserLabel.textColor = UIColor(rgb: 0xFFFFFF, alpha: 0.5)
    headlineLabel.textColor = UIColor(rgb: 0xFFFFFF)
    adLabel.textColor = UIColor(rgb: 0xFFFFFF)
    adLabel.backgroundColor = UIColor(rgb: 0x004AFF)
  }

  private func startAnimation() {
    advertiserLabel.isHidden = true
    skeletonView.showAnimatedGradientSkeleton(
      usingGradient: SkeletonGradient(
        baseColor: baseColor,
        secondaryColor: secondaryColor))
  }
}
