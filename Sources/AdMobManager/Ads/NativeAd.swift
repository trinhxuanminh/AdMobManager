//
//  NativeAdsGlobal.swift
//  MovieIOS7
//
//  Created by Trịnh Xuân Minh on 21/02/2022.
//

import Foundation
import UIKit
import GoogleMobileAds

/// This class returns a NSObject gồm một GADNativeAd.
/// ```
/// import AdMobManager
/// ```
/// ```
/// let nativeAd: NativeAd = NativeAd()
/// ```
/// Use as a data type.
/// - Warning: Requires additional ID before initialization.
public class NativeAd: NSObject {
    
    fileprivate var adUnit_ID: String?
    fileprivate var nativeAd: GADNativeAd?
    fileprivate var adLoader: GADAdLoader!
    fileprivate var isLoading: Bool = false
    fileprivate var configData: (() -> ())?
    fileprivate var limitReloading: Bool = false
    
    public override init() {
        super.init()
        self.adUnit_ID = AdMobManager.shared.getNativeAdID()
        self.load()
        
        AdMobManager.shared.addLimitReloading {
            self.limitReloading = true
        }
    }
    
    func load() {
        if self.isLoading {
            return
        }
        
        if self.isExist() {
            return
        }
        
        if self.limitReloading {
            self.load()
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
    
    /// This function returns a GADNativeAd inside the NativeAd class.
    public func get_Ad() -> GADNativeAd? {
        return self.nativeAd
    }
    
    /// This function will change the command block to execute when the ad has been received.
    /// - Parameter didLoadAd: An executable block of commands.
    public func set_Config_Data(didLoadAd: (() -> ())?) {
        self.configData = didLoadAd
    }
}

extension NativeAd: GADNativeAdLoaderDelegate {
    public func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        self.isLoading = false
        print("NativeAd download error, trying again!")
        self.limitReloading = AdMobManager.shared.getLimitReloadingOfAdsWhenThereIsAnError()
        self.load()
    }
    
    public func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        self.nativeAd = nativeAd
        self.configData?()
    }
}
