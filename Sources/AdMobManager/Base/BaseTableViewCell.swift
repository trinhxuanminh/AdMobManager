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
  
  public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    addComponents()
    setConstraints()
    setProperties()
    setColor()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  func addComponents() {}

  func setConstraints() {}

  func setProperties() {}

  func setColor() {}
}
