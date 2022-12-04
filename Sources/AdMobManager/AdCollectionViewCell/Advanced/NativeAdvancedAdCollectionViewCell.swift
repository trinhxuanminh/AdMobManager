//
//  NativeAdvancedAdCollectionViewCell.swift
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
/// collectionView.register(ofType NativeAdvancedAdCollectionViewCell.self)
/// ```
/// ```
/// func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
///   return collectionView.dequeueCell(ofType: NativeAdvancedAdCollectionViewCell.self, indexPath: indexPath)
/// }
/// ```
/// - Warning: Native Ad will not be displayed without adding ID.
public class NativeAdvancedAdCollectionViewCell: BaseCollectionViewCell {
  public lazy var adView: NativeAdvancedAdView = {
    return NativeAdvancedAdView()
  }()
  
  override func addComponents() {
    addSubview(adView)
  }
  
  override func setConstraints() {
    adView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
}
