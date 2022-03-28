//
//  NativeAd.swift
//  AdMobManager
//
//  Created by Trịnh Xuân Minh on 25/03/2022.
//

import Foundation
import UIKit
import GoogleMobileAds

class NativeAd: NSObject {
    
    fileprivate var adUnit_ID: String?
    fileprivate var nativeAd: GADNativeAd?
    fileprivate var adLoader: GADAdLoader!
    fileprivate var isLoading: Bool = false
    fileprivate var configData: (() -> ())?
    fileprivate var didAddReloadingAd: Bool = false
    
    override init() {
        super.init()
        
        if !self.didAddReloadingAd {
            self.didAddReloadingAd = true
            self.adUnit_ID = AdMobManager.shared.getNativeAdID()
            self.load()
            AdMobManager.shared.addReloadingAd {
                self.load()
            }
        }
    }
    
    func load() {
        if self.isLoading {
            return
        }
        
        if self.isExist() {
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
    
    func get_Ad() -> GADNativeAd? {
        return self.nativeAd
    }
    
    func set_Config_Data(didLoadAd: (() -> ())?) {
        self.configData = didLoadAd
    }
}

extension NativeAd: GADNativeAdLoaderDelegate {
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        self.isLoading = false
        print("NativeAd download error, trying again!")
        if !AdMobManager.shared.getLimitReloadingOfAdsWhenThereIsAnError() {
            self.load()
        }
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        self.nativeAd = nativeAd
        self.configData?()
    }
}
