//
//  Size13NativeAdTableViewCell.swift
//  
//
//  Created by Trịnh Xuân Minh on 13/04/2023.
//

import UIKit
import SnapKit

/// This class returns a UITableViewCell displaying NativeAd.
/// - Warning: Native Ad will not be displayed without adding ID.
public class Size13NativeAdTableViewCell: BaseTableViewCell {
  public lazy var adView: Size13NativeAdView = {
    return Size13NativeAdView()
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
    return Size13NativeAdView.adHeightMinimum(width: width)
  }
}
