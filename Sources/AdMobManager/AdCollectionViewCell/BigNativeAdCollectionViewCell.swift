//
//  BigNativeAdCollectionViewCell.swift
//  AdMobManager
//
//  Created by Trịnh Xuân Minh on 25/03/2022.
//

import UIKit
import SnapKit

/// This class returns a UICollectionViewCell displaying NativeAd.
/// - Warning: Native Ad will not be displayed without adding ID.
public class BigNativeAdCollectionViewCell: BaseCollectionViewCell {
  public lazy var adView: BigNativeAdView = {
    return BigNativeAdView()
  }()
  
  override func addComponents() {
    addSubview(adView)
  }
  
  override func setConstraints() {
    adView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  /// This function returns the minimum recommended height for NativeAdCollectionViewCell.
  public class func adHeightMinimum(width: CGFloat) -> CGFloat {
    let mediaHeight = (width - 100) / 16 * 9
    return (mediaHeight < 120 ? 120 : mediaHeight) + 185
  }
}
