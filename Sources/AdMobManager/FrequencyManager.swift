//
//  File.swift
//  
//
//  Created by Trịnh Xuân Minh on 15/11/2023.
//

import Foundation

class FrequencyManager {
  static let shared = FrequencyManager()
  
  private var countClicks: [String: Int] = [:]
}

extension FrequencyManager {
  func getCount(name: String) -> Int {
    return countClicks[name] ?? 0
  }
  
  func increaseCount(name: String) {
    let count = getCount(name: name)
    countClicks[name] = count + 1
  }
}
