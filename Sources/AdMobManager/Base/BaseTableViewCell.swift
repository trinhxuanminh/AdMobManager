//
//  BaseTableViewCell.swift
//  
//
//  Created by Trịnh Xuân Minh on 18/12/2022.
//

import UIKit

public class BaseTableViewCell: UITableViewCell, ViewProtocol {
  public override func awakeFromNib() {
    super.awakeFromNib()
    addComponents()
    setConstraints()
    setProperties()
    setColor()
  }
  
  public required init?(coder: NSCoder) {
    super.init(coder: coder)
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
