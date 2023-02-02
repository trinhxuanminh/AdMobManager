//
//  Size1NativeAdCollectionViewCell.swift
//  
//
//  Created by Trịnh Xuân Minh on 02/02/2023.
//

import UIKit
import SnapKit

/// This class returns a UICollectionViewCell displaying NativeAd.
/// - Warning: Native Ad will not be displayed without adding ID.
public class Size1NativeAdCollectionViewCell: BaseCollectionViewCell {
  public lazy var adView: Size1NativeAdView = {
    return Size1NativeAdView()
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
  public class func adHeight() -> CGFloat {
    return Size1NativeAdView.adHeight()
  }
}
