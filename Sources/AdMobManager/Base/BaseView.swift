//
//  BaseView.swift
//  
//
//  Created by Trịnh Xuân Minh on 24/06/2022.
//

import UIKit

public class BaseView: UIView, ViewProtocol {
  public override func awakeFromNib() {
    super.awakeFromNib()
    addComponents()
    setConstraints()
    setProperties()
    setColor()
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
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
