//
//  Interstitial.swift
//  
//
//  Created by Trịnh Xuân Minh on 23/08/2023.
//

import Foundation

struct Interstitial: AdConfigProtocol {
  let name: String
  let id: String
  let description: String?
  let start: Int?
  let frequency: Int?
}
