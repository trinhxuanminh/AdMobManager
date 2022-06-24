//
//  AdProtocol.swift
//  
//
//  Created by Trịnh Xuân Minh on 23/06/2022.
//

import Foundation

protocol AdProtocol {
  func setAdUnitID(_ adUnitID: String)
  func setAdReloadTime(_ adReloadTime: Double)
  func isPresent() -> Bool
  func load()
  func isExist() -> Bool
  func isReady() -> Bool
  func show(willPresent: (() -> Void)?,
            willDismiss: (() -> Void)?,
            didDismiss: (() -> Void)?)
}

protocol ReuseAdProtocol: AdProtocol {
  func setTimeBetween(_ timeBetween: Double)
}

protocol OnceAdProtocol: AdProtocol {
  func stopLoading()
}
