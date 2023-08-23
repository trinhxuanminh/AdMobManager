//
//  File.swift
//  
//
//  Created by Trịnh Xuân Minh on 23/08/2023.
//

import Foundation

struct AdMobConfig: Codable {
  let status: Bool
  let appOpens: [AppOpen]
  let rewardeds: [Rewarded]
  let interstitials: [Interstitial]
  let rewardedInterstitials: [RewardedInterstitial]
  let banners: [Banner]
  let natives: [Native]
}
