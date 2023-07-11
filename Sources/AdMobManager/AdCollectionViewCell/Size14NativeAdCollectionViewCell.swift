//
//  Size14NativeAdCollectionViewCell.swift
//  
//
//  Created by Trịnh Xuân Minh on 11/07/2023.
//

import UIKit
import SnapKit

/// This class returns a UICollectionViewCell displaying NativeAd.
/// - Warning: Native Ad will not be displayed without adding ID.
public class Size14NativeAdCollectionViewCell: BaseCollectionViewCell {
  public lazy var adView: Size14NativeAdView = {
    return Size14NativeAdView()
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
    return Size14NativeAdView.adHeight()
  }
}
