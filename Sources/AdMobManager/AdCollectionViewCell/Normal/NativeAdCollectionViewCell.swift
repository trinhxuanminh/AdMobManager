//
//  NativeAdCollectionViewCell.swift
//  AdMobManager
//
//  Created by Trịnh Xuân Minh on 25/03/2022.
//

import UIKit
import SnapKit

/// This class returns a UICollectionViewCell displaying NativeAd.
/// ```
/// import AdMobManager
/// ```
/// ```
/// collectionView.register(ofType NativeAdCollectionViewCell.self)
/// ```
/// ```
/// func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
///   return collectionView.dequeue(ofType: NativeAdCollectionViewCell.self, indexPath: indexPath)
/// }
/// ```
/// - Warning: Native Ad will not be displayed without adding ID.
public class NativeAdCollectionViewCell: BaseCollectionViewCell {
  public lazy var adView: NativeAdView = {
    return NativeAdView()
  }()
  
  public override func addSubview(_ view: UIView) {
    addSubview(adView)
  }
  
  override func setConstraints() {
    adView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
}
