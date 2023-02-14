//
//  Size4NativeAdTableViewCell.swift
//  
//
//  Created by Trịnh Xuân Minh on 14/02/2023.
//

import UIKit
import SnapKit

/// This class returns a UITableViewCell displaying NativeAd.
/// - Warning: Native Ad will not be displayed without adding ID.
public class Size4NativeAdTableViewCell: BaseTableViewCell {
  public lazy var adView: Size4NativeAdView = {
    return Size4NativeAdView()
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
    return Size4NativeAdView.adHeight()
  }
}
