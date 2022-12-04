//
//  AdProtocol.swift
//  
//
//  Created by Trịnh Xuân Minh on 23/06/2022.
//

import Foundation

protocol AdProtocol {
  func setAdUnitID(_ id: String)
  func isPresent() -> Bool
  func load()
  func isExist() -> Bool
  func isReady() -> Bool
  func setTimeBetween(_ timeBetween: Double)
  func show(willPresent: (() -> Void)?,
            willDismiss: (() -> Void)?,
            didDismiss: (() -> Void)?,
            didFail: (() -> Void)?)
}
