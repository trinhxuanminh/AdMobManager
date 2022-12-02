//
//  NativeAdvancedAdView.swift
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
/// Minimum **height** = width  / 16 * 9 + 160
/// - Warning: Native Ad will not be displayed without adding ID.
@IBDesignable public class NativeAdvancedAdView: BaseView, GADVideoControllerDelegate {
  @IBOutlet var contentView: UIView!
  @IBOutlet weak var callToActionButton: UIButton!
  @IBOutlet weak var storeLabel: UILabel!
  @IBOutlet weak var priceLabel: UILabel!
  @IBOutlet weak var bodyLabel: UILabel!
  @IBOutlet weak var advertiserLabel: UILabel!
  @IBOutlet weak var headlineLabel: UILabel!
  @IBOutlet weak var adLabel: UILabel!
  @IBOutlet weak var nativeAdView: GADNativeAdView!
  @IBOutlet weak var skeletonView: UIView!
  @IBOutlet weak var starImageView: UIImageView!
  @IBOutlet weak var mediaView: GADMediaView!

  private var listAd: [NativeAd?] = [NativeAd()]
  private var indexState: Int = 0
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

  override func addComponents() {
    Bundle.module.loadNibNamed(String(describing: NativeAdvancedAdView.self), owner: self, options: nil)
    addSubview(contentView)
  }

  override func setConstraints() {
    contentView.frame = bounds
    contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
  }

  override func setProperties() {
    skeletonView.layer.borderWidth = 1.0
  }

  /// This function returns the minimum recommended height for NativeAdvancedAdView.
  public class func adHeightMinimum(width: CGFloat) -> CGFloat {
    return width / 16 * 9 + 160
  }

  /// This function helps to change the ads in the cell.
  /// - Parameter index: Index of ads to show in the list.
  public func setAd(index: Int = 0) {
    guard index >= 0 else {
      return
    }
    self.indexState = index
    if index >= listAd.count {
      for _ in listAd.count..<index {
        listAd.append(nil)
      }
      self.listAd.append(NativeAd())
    } else if listAd[index] == nil {
      self.listAd[index] = NativeAd()
    }
    configData(ad: listAd[index]?.ad(), index: index)
    listAd[index]?.setBinding(index: index) { [weak self] index in
      guard let self = self else {
        return
      }
      self.configData(ad: self.listAd[index]?.ad(), index: index)
    }
  }

  /// Change the color of animated.
  /// - Parameter base: Basic background color. Default is **gray**.
  /// - Parameter secondary: Animated colors. Default is **white**.
  public func setAnimatedColor(base: UIColor? = nil, secondary: UIColor? = nil) {
    if let secondary = secondary {
      self.secondaryColor = secondary
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

extension NativeAdvancedAdView {
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

    nativeAdView.nativeAd = nativeAd

    (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline

    nativeAdView.mediaView?.mediaContent = nativeAd.mediaContent
    mediaView.isHidden = false
    let mediaContent = nativeAd.mediaContent
    if mediaContent.hasVideoContent {
      mediaContent.videoController.delegate = self
    }

    (nativeAdView.bodyView as? UILabel)?.text = nativeAd.body

    (nativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)

    (nativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image

    (nativeAdView.starRatingView as? UIImageView)?.image = imageOfStars(from: nativeAd.starRating)
    nativeAdView.starRatingView?.isHidden = nativeAd.starRating == nil

    (nativeAdView.storeView as? UILabel)?.text = nativeAd.store
    nativeAdView.storeView?.isHidden = nativeAd.store == nil

    (nativeAdView.priceView as? UILabel)?.text = nativeAd.price
    nativeAdView.priceView?.isHidden = nativeAd.price == nil

    (nativeAdView.advertiserView as? UILabel)?.text = nativeAd.advertiser
    nativeAdView.advertiserView?.isHidden = nativeAd.advertiser == nil

    nativeAdView.callToActionView?.isUserInteractionEnabled = false
  }

  private func imageOfStars(from starRating: NSDecimalNumber?) -> UIImage? {
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

  private func startAnimation() {
    priceLabel.isHidden = true
    storeLabel.isHidden = true
    starImageView.isHidden = true
    mediaView.isHidden = true
    advertiserLabel.isHidden = true
    skeletonView.showAnimatedGradientSkeleton(
      usingGradient: SkeletonGradient(
        baseColor: baseColor,
        secondaryColor: secondaryColor))
    headlineLabel.text = nil
    callToActionButton.setTitle(nil, for: .normal)
    bodyLabel.text = nil
  }
}
