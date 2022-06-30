//
//  NativeAdTableViewCell.swift
//  AdMobManager
//
//  Created by Trịnh Xuân Minh on 28/03/2022.
//

import UIKit
import GoogleMobileAds
import SkeletonView

@IBDesignable public class NativeAdTableViewCell: BaseTableViewCell {

  @IBOutlet weak var nativeAdView: GADNativeAdView!
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

  public override func removeFromSuperview() {
    for index in 0..<listAd.count {
      listAd[index] = nil
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

  override func setColor() {
    callToActionButton.backgroundColor = UIColor(rgb: 0x87A605)
    setLightColor()
  }

  /// This function returns the minimum recommended height for NativeAdTableViewCell.
  public class func adHeightMinimum() -> CGFloat {
    return 100.0
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
    configData(ad: listAd[index]?.ad(), index: index)
    listAd[index]?.setConfigData(index: index) { [weak self] index in
      guard let self = self else {
        return
      }
      self.configData(ad: self.listAd[index]?.ad(), index: index)
    }
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

extension NativeAdTableViewCell {
  private func configData(ad: GADNativeAd?, index: Int) {
    guard index == indexState else {
      return
    }
    guard let nativeAd = ad else {
      isLoading = true
      guard didFirstLoadAd else {
        return
      }
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
    headlineLabel.text = Text.headline
    callToActionButton.setTitle(Text.callToAction, for: .normal)
    skeletonView.showAnimatedGradientSkeleton(
      usingGradient: SkeletonGradient(
        baseColor: baseColor,
        secondaryColor: secondaryColor))
  }
}
