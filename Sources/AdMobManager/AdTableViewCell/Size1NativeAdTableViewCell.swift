//
//  Size1NativeAdTableViewCell.swift
//  
//
//  Created by Trịnh Xuân Minh on 18/12/2022.
//

import UIKit
import SnapKit

/// This class returns a UITableViewCell displaying NativeAd.
/// - Warning: Native Ad will not be displayed without adding ID.
public class Size1NativeAdTableViewCell: BaseTableViewCell {
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
  
  /// This function returns the minimum recommended height.
  public class func adHeight() -> CGFloat {
    return Size1NativeAdView.adHeight()
  }
}
