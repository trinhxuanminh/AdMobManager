//
//  File.swift
//  
//
//  Created by Trịnh Xuân Minh on 23/08/2023.
//

import Foundation

struct AdMobConfig: Codable {
  let status: Bool
  var splashs: [Splash]?
  var appOpen: AppOpen?
  var rewardeds: [Rewarded]?
  var interstitials: [Interstitial]?
  var rewardedInterstitials: [RewardedInterstitial]?
  var banners: [Banner]?
  var natives: [Native]?
}
