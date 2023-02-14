//
//  BonusNativeAdCollectionViewCell.swift
//  
//
//  Created by Trịnh Xuân Minh on 14/02/2023.
//

import UIKit
import SnapKit

/// This class returns a UICollectionViewCell displaying NativeAd.
/// - Warning: Native Ad will not be displayed without adding ID.
public class BonusNativeAdCollectionViewCell: BaseCollectionViewCell {
  public lazy var adView: BonusNativeAdView = {
    return BonusNativeAdView()
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
  public class func adHeight() -> CGFloat {
    return BonusNativeAdView.adHeight()
  }
}
