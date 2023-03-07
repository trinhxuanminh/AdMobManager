//
//  Size10NativeAdCollectionViewCell.swift
//  
//
//  Created by Trịnh Xuân Minh on 07/03/2023.
//

import UIKit
import SnapKit

/// This class returns a UICollectionViewCell displaying NativeAd.
/// - Warning: Native Ad will not be displayed without adding ID.
public class Size10NativeAdCollectionViewCell: BaseCollectionViewCell {
  public lazy var adView: Size10NativeAdView = {
    return Size10NativeAdView()
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
    return Size10NativeAdView.adHeight()
  }
}
