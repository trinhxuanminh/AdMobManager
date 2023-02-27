//
//  Size7NativeAdTableViewCell.swift
//  
//
//  Created by Trịnh Xuân Minh on 24/02/2023.
//

import UIKit
import SnapKit

/// This class returns a UITableViewCell displaying NativeAd.
/// - Warning: Native Ad will not be displayed without adding ID.
public class Size7NativeAdTableViewCell: BaseTableViewCell {
  public lazy var adView: Size7NativeAdView = {
    return Size7NativeAdView()
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
    return Size7NativeAdView.adHeight()
  }
}
