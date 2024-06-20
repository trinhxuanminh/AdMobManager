//
//  RewardedInterstitial.swift
//  
//
//  Created by Trịnh Xuân Minh on 23/08/2023.
//

import Foundation

struct RewardedInterstitial: AdConfigProtocol {
  let name: String
  let status: Bool
  let id: String
  let isAuto: Bool?
  let description: String?
}
