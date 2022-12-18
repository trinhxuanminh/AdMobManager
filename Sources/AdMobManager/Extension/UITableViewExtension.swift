//
//  UITableViewExtension.swift
//  
//
//  Created by Trịnh Xuân Minh on 18/12/2022.
//

import UIKit

extension UITableView {
  public func register(ofType type: AnyClass) {
    register(type, forCellReuseIdentifier: String(describing: type.self))
  }

  public func dequeue<T>(ofType type: T.Type, indexPath: IndexPath) -> T {
    return dequeueReusableCell(withIdentifier: String(describing: T.self), for: indexPath) as! T
  }
}
