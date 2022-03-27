//
//  NSObjectExtension.swift
//  AdMobManager
//
//  Created by Trịnh Xuân Minh on 25/03/2022.
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
