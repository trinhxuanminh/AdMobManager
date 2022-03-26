//
//  NSObjectExtension.swift
//  Strem_IO
//
//  Created by Trịnh Xuân Minh on 27/05/2021.
//

import Foundation

extension NSObject {
    public class var className: String {
        return String(describing: self)
    }
    
    public var className: String {
        return String(describing: self)
    }
}
