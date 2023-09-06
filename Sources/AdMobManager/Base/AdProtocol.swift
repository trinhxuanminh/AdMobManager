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
  func show(rootViewController: UIViewController,
            didShow: Handler?,
            didFail: Handler?)
}
