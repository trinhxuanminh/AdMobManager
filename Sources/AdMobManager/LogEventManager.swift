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
  
  case cmpClickConsent
  case cmpNotConsent
  
  var name: String {
    switch self {
    case .remoteConfigLoadFailFirstOpen:
      return "RemoteConfig_LoadFail_First_Open"
    case .remoteConfigLoadFailLaunchApp:
      return "RemoteConfig_LoadFail_Launch_App"
    case .cmpClickConsent:
      return "CMP_Click_Consent"
    case .cmpNotConsent:
      return "CMP_Not_Consent"
    }
  }
  
  var parameters: [String: Any]? {
    switch self {
    case .remoteConfigLoadFailFirstOpen:
      return [AnalyticsParameterContent: "Error loading RemoteConfig ads the first time opening the app"]
    case .remoteConfigLoadFailLaunchApp:
      return [AnalyticsParameterContent: "Error loading RemoteConfig ads from the second time opening the app"]
    default:
      return nil
    }
  }
}
