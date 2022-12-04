//
//  NativeAdCollectionViewCell.swift
//  AdMobManager
//
//  Created by Trịnh Xuân Minh on 25/03/2022.
//

import UIKit
import GoogleMobileAds

/// This class returns a UICollectionViewCell displaying NativeAd.
/// ```
/// import AdMobManager
/// ```
/// ```
/// collectionView.registerAds(ofType: NativeAdCollectionViewCell.self)
/// ```
/// ```
/// func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
///   return collectionView.dequeue(ofType: NativeAdCollectionViewCell.self, indexPath: indexPath)
/// }
/// ```
/// - Warning: Native Ad will not be displayed without adding ID.
@IBDesignable public class NativeAdCollectionViewCell: BaseCollectionViewCell {
  @IBOutlet var nativeAdView: GADNativeAdView!
  @IBOutlet weak var headlineLabel: UILabel!
  @IBOutlet weak var adLabel: UILabel!
  @IBOutlet weak var advertiserLabel: UILabel!
  @IBOutlet weak var callToActionButton: UIButton!
  @IBOutlet weak var skeletonView: UIView!
//
//  private var listAd: [NativeAd?] = [NativeAd()]
//  private var indexState: Int = 0
//  private var baseColor = UIColor(rgb: 0x808080)
//  private var secondaryColor = UIColor(rgb: 0xFFFFFF)
//  private var isLoading = false
//  private var didFirstLoadAd = false
//
//  public override func awakeFromNib() {
//    super.awakeFromNib()
//    setAd()
//  }
//
//  public override init(frame: CGRect) {
//    super.init(frame: frame)
//    setAd()
//  }
//
//  required init?(coder: NSCoder) {
//    super.init(coder: coder)
//  }
//
//  public override func removeFromSuperview() {
//    for index in 0..<listAd.count {
//      self.listAd[index] = nil
//    }
//    super.removeFromSuperview()
//  }
//
//  public override func draw(_ rect: CGRect) {
//    super.draw(rect)
//    guard isLoading else {
//      return
//    }
//    startAnimation()
//  }
//
//  /// This function returns the minimum recommended height for NativeAdCollectionViewCell.
//  public class func adHeightMinimum() -> CGFloat {
//    return 100.0
//  }
//
//  /// This function helps to change the ads in the cell.
//  /// - Parameter index: Index of ads to show in the list.
//  public func setAd(index: Int = 0) {
//    guard index >= 0 else {
//      return
//    }
//    self.indexState = index
//    if index >= listAd.count {
//      for _ in listAd.count..<index {
//        self.listAd.append(nil)
//      }
//      self.listAd.append(NativeAd())
//    } else if listAd[index] == nil {
//      self.listAd[index] = NativeAd()
//    }
//    configData(ad: listAd[index]?.ad(), index: index)
//    listAd[index]?.setBinding(index: index) { [weak self] index in
//      guard let self = self else {
//        return
//      }
//      self.configData(ad: self.listAd[index]?.ad(), index: index)
//    }
//  }
//
//  /// Change the color of animated.
//  /// - Parameter base: Basic background color. Default is **gray**.
//  /// - Parameter secondary: Animated colors. Default is **white**.
//  public func setAnimatedColor(base: UIColor? = nil, secondary: UIColor? = nil) {
//    if let secondary = secondary {
//      self.secondaryColor = secondary
//    }
//    if let base = base {
//      self.baseColor = base
//    }
//    guard isLoading else {
//      return
//    }
//    skeletonView.updateAnimatedGradientSkeleton(
//      usingGradient: SkeletonGradient(
//        baseColor: baseColor,
//        secondaryColor: secondaryColor))
//  }
}
