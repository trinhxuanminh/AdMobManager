//
//  MediumNativeAdCollectionViewCell.swift
//  
//
//  Created by Trịnh Xuân Minh on 05/12/2022.
//

import UIKit
import SnapKit

/// This class returns a UICollectionViewCell displaying NativeAd.
/// - Warning: Native Ad will not be displayed without adding ID.
public class MediumNativeAdCollectionViewCell: BaseCollectionViewCell {
  public lazy var adView: MediumNativeAdView = {
    return MediumNativeAdView()
  }()
  
  override func addComponents() {
    addSubview(adView)
  }
  
  override func setConstraints() {
    adView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  /// This function returns the minimum recommended height.
  public class func adHeightMinimum(width: CGFloat) -> CGFloat {
    let mediaHeight = (width - 10) / 16 * 9
    return (mediaHeight < 120 ? 120 : mediaHeight) + 60
  }
}
