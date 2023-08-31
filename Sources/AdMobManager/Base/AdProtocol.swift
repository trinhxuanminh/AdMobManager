//
//  AdProtocol.swift
//  
//
//  Created by Trịnh Xuân Minh on 23/06/2022.
//

import UIKit

protocol AdProtocol {
  func config(ad: Any)
  func isPresent() -> Bool
  func load()
  func isExist() -> Bool
  func isReady() -> Bool
  func show(rootViewController: UIViewController,
            willPresent: Handler?,
            willDismiss: Handler?,
            didDismiss: Handler?,
            didFail: Handler?)
}
