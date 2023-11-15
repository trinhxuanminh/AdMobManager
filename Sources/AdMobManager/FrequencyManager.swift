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
  func check(_ adConfig: AdConfigProtocol) -> Bool {
    guard
      let interstitial = adConfig as? Interstitial,
      let start = interstitial.start,
      let frequency = interstitial.frequency
    else {
      return true
    }
    var countClick = 0
    if let count = countClicks[adConfig.name] {
      countClick = count
    }
    countClick += 1
    countClicks[adConfig.name] = countClick
    
    guard countClick >= start else {
      return false
    }
    return (countClick - start) % frequency == 0
  }
}
