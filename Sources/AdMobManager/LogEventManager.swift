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
  case register
  
  case remoteConfigLoadFail
  case remoteConfigTimeout
  case remoteConfigStartLoad
  case remoteConfigSuccess
  
  case cmpCheckConsent
  case cmpNotRequestConsent
  case cmpRequestConsent
  case cmpConsentInformationError
  case cmpConsentFormError
  case cmpClickConsent
  case cmpNotConsent
  case cmpAutoConsent
  
  case connectedAppsFlyer
  case noConnectAppsFlyer
  case agreeTracking
  case noTracking
  
  var name: String {
    switch self {
    case .remoteConfigLoadFail:
      return "RemoteConfig_LoadFail"
    case .remoteConfigTimeout:
      return "RemoteConfig_Timeout"
    case .register:
      return "Register"
    case .remoteConfigStartLoad:
      return "RemoteConfig_Start_Load"
    case .remoteConfigSuccess:
      return "remoteConfig_Success"
    case .cmpCheckConsent:
      return "CMP_Check_Consent"
    case .cmpNotRequestConsent:
      return "CMP_Not_Request_Consent"
    case .cmpRequestConsent:
      return "CMP_Request_Consent"
    case .cmpConsentInformationError:
      return "CMP_Consent_Information_Error"
    case .cmpConsentFormError:
      return "CMP_Consent_Form_Error"
    case .cmpClickConsent:
      return "CMP_Click_Consent"
    case .cmpNotConsent:
      return "CMP_Not_Consent"
    case .cmpAutoConsent:
      return "CMP_Auto_Consent"
    case .connectedAppsFlyer:
      return "Connected_AppsFlyer"
    case .noConnectAppsFlyer:
      return "NoConnect_AppsFlyer"
    case .agreeTracking:
      return "Agree_Tracking"
    case .noTracking:
      return "No_Tracking"
    }
  }
  
  var parameters: [String: Any]? {
    switch self {
    default:
      return nil
    }
  }
}
