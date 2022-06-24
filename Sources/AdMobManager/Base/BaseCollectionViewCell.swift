//
//  BaseCollectionViewCell.swift
//  
//
//  Created by Trịnh Xuân Minh on 24/06/2022.
//

import UIKit

public class BaseCollectionViewCell: UICollectionViewCell, ViewProtocol {

  public override func awakeFromNib() {
    super.awakeFromNib()
    addComponents()
    setConstraints()
    setProperties()
    setColor()
  }

  func addComponents() {}

  func setConstraints() {}

  func setProperties() {}

  func setColor() {}
}
