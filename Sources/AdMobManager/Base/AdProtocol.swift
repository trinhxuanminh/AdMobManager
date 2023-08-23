//
//  AdProtocol.swift
//  
//
//  Created by Trịnh Xuân Minh on 23/06/2022.
//

import Foundation

protocol AdProtocol {
  func config(ad: Any)
  func isPresent() -> Bool
  func load()
  func isExist() -> Bool
  func isReady() -> Bool
  func show(willPresent: Handler?,
            willDismiss: Handler?,
            didDismiss: Handler?,
            didFail: Handler?)
}
