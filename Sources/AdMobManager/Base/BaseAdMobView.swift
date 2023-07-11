//
//  BaseAdMobView.swift
//  
//
//  Created by Trịnh Xuân Minh on 24/06/2022.
//

import UIKit

open class BaseAdMobView: UIView, AdMobViewProtocol {
  public override func awakeFromNib() {
    super.awakeFromNib()
    addComponents()
    setConstraints()
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    addComponents()
    setConstraints()
  }

  required public init?(coder: NSCoder) {
    super.init(coder: coder)
  }

  func addComponents() {}

  func setConstraints() {}
}
