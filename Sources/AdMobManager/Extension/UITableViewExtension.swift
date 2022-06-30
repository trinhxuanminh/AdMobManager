//
//  File.swift
//  
//
//  Created by Trịnh Xuân Minh on 30/06/2022.
//

import UIKit

extension UITableView {
  func registerAds(ofType type: AnyClass, bundle: Bundle = AdMobManager.bundle) {
    register(UINib(nibName: String(describing: type.self), bundle: bundle),
             forCellReuseIdentifier: String(describing: type.self))
  }
  
  func dequeueCell<T>(ofType type: T.Type, indexPath: IndexPath) -> T {
    return dequeueReusableCell(withIdentifier: String(describing: type.self), for: indexPath) as! T
  }
}
