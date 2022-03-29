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
    fileprivate var configData: (() -> ())?
    fileprivate var didAddReloadingAd: Bool = false
    fileprivate var isLoading: Bool = false
    
    override init() {
        super.init()
        
        if !self.didAddReloadingAd {
            self.didAddReloadingAd = true
            self.adUnit_ID = AdMobManager.shared.getNativeAdID()
            self.request()
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
        
        guard let rootViewController = UIApplication.topStackViewController() else {
            print("Can't find RootViewController!")
            return
        }
        
        self.isLoading = true
        
        self.adLoader = GADAdLoader(adUnitID: adUnit_ID,
                               rootViewController: rootViewController,
                               adTypes: [.native],
                               options: nil)
        self.adLoader.delegate = self
        self.adLoader.load(GADRequest())
    }
    
    func request() {
        let adReloadTime: Int? = AdMobManager.shared.getAdReloadTime()
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(adReloadTime == nil ? 0 : adReloadTime!), execute: self.load)
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
        print("NativeAd download error, trying again!")
        self.isLoading = false
        self.request()
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        self.nativeAd = nativeAd
        DispatchQueue.main.async {
            self.configData?()
        }
    }
}
