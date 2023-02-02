//
//  SmallNativeAdTableViewCell.swift
//  
//
//  Created by Trịnh Xuân Minh on 18/12/2022.
//

import UIKit
import SnapKit

/// This class returns a UITableViewCell displaying NativeAd.
/// - Warning: Native Ad will not be displayed without adding ID.
public class SmallNativeAdTableViewCell: BaseTableViewCell {
  public lazy var adView: SmallNativeAdView = {
    return SmallNativeAdView()
  }()
  
  override func addComponents() {
    addSubview(adView)
  }
  
  override func setConstraints() {
    adView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  /// This function returns the minimum recommended height for NativeAdTableViewCell.
  public class func adHeightMinimum() -> CGFloat {
    return 100.0
  }
}
