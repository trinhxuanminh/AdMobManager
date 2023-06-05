//
//  Size12NativeAdCollectionViewCell.swift
//  
//
//  Created by Trịnh Xuân Minh on 05/06/2023.
//

import UIKit
import SnapKit

/// This class returns a UICollectionViewCell displaying NativeAd.
/// - Warning: Native Ad will not be displayed without adding ID.
public class Size12NativeAdCollectionViewCell: BaseCollectionViewCell {
  public lazy var adView: Size12NativeAdView = {
    return Size12NativeAdView()
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
    return Size12NativeAdView.adHeight()
  }
}
