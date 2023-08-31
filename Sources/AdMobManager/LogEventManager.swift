//
//  File.swift
//  
//
//  Created by Trịnh Xuân Minh on 31/08/2023.
//

import Foundation
import FirebaseAnalytics

class LogEventManager {
  static let shared = LogEventManager()
  
  func log(event: Event) {
    Analytics.logEvent(event.name, parameters: event.parameters)
  }
}

enum Event {
  case remoteConfigLoadFailFirstOpen
  case remoteConfigLoadFailLaunchApp
  
  var name: String {
    switch self {
    case .remoteConfigLoadFailFirstOpen:
      return "RemoteConfig_LoadFail_First_Open"
    case .remoteConfigLoadFailLaunchApp:
      return "RemoteConfig_LoadFail_Launch_App"
    }
  }
  
  var parameters: [String: Any]? {
    switch self {
    case .remoteConfigLoadFailFirstOpen:
      return [AnalyticsParameterContent: "Error loading RemoteConfig ads the first time opening the app"]
    case .remoteConfigLoadFailLaunchApp:
      return [AnalyticsParameterContent: "Error loading RemoteConfig ads from the second time opening the app"]
    }
  }
}
