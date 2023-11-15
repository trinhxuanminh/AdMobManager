//
//  AdProtocol.swift
//  
//
//  Created by Trịnh Xuân Minh on 23/06/2022.
//

import UIKit

protocol AdProtocol {
  func config(id: String)
  func isPresent() -> Bool
  func show(rootViewController: UIViewController,
            didFail: Handler?,
            didEarnReward: Handler?,
            didHide: Handler?)
}

extension AdProtocol {
  func config(timeout: Double) {}
}
