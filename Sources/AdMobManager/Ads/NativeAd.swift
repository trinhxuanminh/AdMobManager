//
//  NativeAdsGlobal.swift
//  MovieIOS7
//
//  Created by Trịnh Xuân Minh on 21/02/2022.
//

import Foundation
import UIKit
import GoogleMobileAds

public class NativeAd: NSObject {
    
    fileprivate var adUnit_ID: String?
    fileprivate var nativeAd: GADNativeAd?
    fileprivate var adLoader: GADAdLoader!
    fileprivate var isLoading: Bool = false
    fileprivate var configData: (() -> ())?
    
    public override init() {
        super.init()
        self.adUnit_ID = AdMobManager.shared.getNativeAdID()
        self.load()
    }
    
    func load() {
        if self.isLoading {
            return
        }
        
        guard let adUnit_ID = self.adUnit_ID else {
            print("No NativeAd ID!")
            return
        }
        
        guard let topViewController = UIApplication.topStackViewController() else {
            print("Can't find RootViewController!")
            return
        }
        
        self.isLoading = true
        
        self.adLoader = GADAdLoader(adUnitID: adUnit_ID,
                               rootViewController: topViewController,
                               adTypes: [.native],
                               options: nil)
        self.adLoader.delegate = self
        self.adLoader.load(GADRequest())
    }
    
    func isExist() -> Bool {
        return self.nativeAd != nil
    }
    
    public func get_Ad() -> GADNativeAd? {
        return self.nativeAd
    }
    
    public func set_Config_Data(didLoadAd: (() -> ())?) {
        self.configData = didLoadAd
    }
}

extension NativeAd: GADNativeAdLoaderDelegate {
    public func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        self.isLoading = false
        self.load()
    }
    
    public func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        self.nativeAd = nativeAd
        self.configData?()
    }
}
