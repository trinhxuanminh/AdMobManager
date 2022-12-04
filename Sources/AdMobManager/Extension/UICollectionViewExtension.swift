//
//  File.swift
//  
//
//  Created by Trịnh Xuân Minh on 30/06/2022.
//

import UIKit

extension UICollectionView {
  public func register(ofType type: AnyClass) {
    register(type, forCellWithReuseIdentifier: String(describing: type.self))
  }

  public func dequeue<T>(ofType type: T.Type, indexPath: IndexPath) -> T {
    return dequeueReusableCell(withReuseIdentifier: String(describing: T.self), for: indexPath) as! T
  }
}
