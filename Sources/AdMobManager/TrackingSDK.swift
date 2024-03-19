//
//  TrackingSDK.swift
//  TrackingSDK
//
//  Created by Trịnh Xuân Minh on 16/11/2023.
//

import UIKit
import AppTrackingTransparency
import AppsFlyerLib
import FirebaseAnalytics
import AdSupport
import PurchaseConnector
import StoreKit
import AppsFlyerAdRevenue

/// Supports MMP AppsFlyer and ATT Tracking integration.
/// ```
/// import TrackingSDK
/// ```
/// - Warning: Available for Swift 5.3, Xcode 12.5 (macOS Big Sur). Support from iOS 13.0 or newer.
public class TrackingSDK: NSObject {
  public static var shared = TrackingSDK()
  
  public func initialize(devKey: String, appID: String, timeout: Double? = nil) {
    AppsFlyerLib.shared().appsFlyerDevKey = devKey
    AppsFlyerLib.shared().appleAppID = appID
    
    PurchaseConnector.shared().purchaseRevenueDelegate = self
    PurchaseConnector.shared().purchaseRevenueDataSource = self
    PurchaseConnector.shared().autoLogPurchaseRevenue = [.autoRenewableSubscriptions, .inAppPurchases]
    
    if let timeout {
      AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: timeout)
    }
    
    NotificationCenter
      .default
      .addObserver(self,
                   selector: #selector(sendLaunch),
                   name: UIApplication.didBecomeActiveNotification,
                   object: nil)
    
    AppsFlyerLib.shared().start(completionHandler: { (dictionary, error) in
      guard error == nil else {
        print("TrackingSDK: \(String(describing: error))!")
        LogEventManager.shared.log(event: .noConnectAppsFlyer)
        return
      }
      print("TrackingSDK: \(String(describing: dictionary))")
      LogEventManager.shared.log(event: .connectedAppsFlyer)
    })
    
    AppsFlyerAdRevenue.start()
    
    if #available(iOS 14, *),
       ATTrackingManager.trackingAuthorizationStatus == .authorized {
      Analytics.setAnalyticsCollectionEnabled(true)
    }
  }
  
  public func debug(enable: Bool) {
    AppsFlyerLib.shared().isDebug = enable
  }
  
  public func status() -> Bool {
    guard
      #available(iOS 14, *),
      ATTrackingManager.trackingAuthorizationStatus == .notDetermined
    else {
      return false
    }
    return true
  }
  
  public func requestAuthorization(completed: Handler?) {
    guard
      #available(iOS 14, *),
      status()
    else {
      completed?()
      return
    }
    ATTrackingManager.requestTrackingAuthorization { status in
      switch status {
      case .authorized:
        print("TrackingSDK: Enable!")
        print("TrackingSDK: \(ASIdentifierManager.shared().advertisingIdentifier)")
        Analytics.setAnalyticsCollectionEnabled(true)
        LogEventManager.shared.log(event: .agreeTracking)
      default:
        print("TrackingSDK: Disable!")
        Analytics.setAnalyticsCollectionEnabled(false)
        LogEventManager.shared.log(event: .noTracking)
      }
      completed?()
    }
  }
}

extension TrackingSDK: PurchaseRevenueDataSource, PurchaseRevenueDelegate {
  public func didReceivePurchaseRevenueValidationInfo(_ validationInfo: [AnyHashable : Any]?,
                                                      error: Error?
  ) {
    print("PurchaseRevenueDelegate: \(String(describing: validationInfo))")
    print("PurchaseRevenueDelegate: \(String(describing: error))")
  }
  
  public func purchaseRevenueAdditionalParameters(for products: Set<SKProduct>,
                                                  transactions: Set<SKPaymentTransaction>?
  ) -> [AnyHashable : Any]? {
    return [
      "additionalParameters": [
        "param1": "value1",
        "param2": "value2"
      ]
    ]
  }
}

extension TrackingSDK {
  @objc private func sendLaunch() {
    AppsFlyerLib.shared().start()
    PurchaseConnector.shared().startObservingTransactions()
  }
}
