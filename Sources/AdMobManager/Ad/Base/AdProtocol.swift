//
//  AdProtocol.swift
//  
//
//  Created by Trịnh Xuân Minh on 23/06/2022.
//

import UIKit

@objc protocol AdProtocol {
  func config(id: String)
  func isPresent() -> Bool
  @objc optional func isExist() -> Bool
  func show(rootViewController: UIViewController,
            didFail: Handler?,
            didEarnReward: Handler?,
            didHide: Handler?)
}

extension AdProtocol {
  func config(timeout: Double) {}
  func config(didFail: Handler?, didSuccess: Handler?) {}
}
