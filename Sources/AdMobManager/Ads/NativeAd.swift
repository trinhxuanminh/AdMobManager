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
    fileprivate var configData: (() -> ())?
    
    func load() {
        guard let adUnit_ID = self.adUnit_ID else {
            return
        }
        
        self.adNativeLoader = GADAdLoader(adUnitID: adUnit_ID,
                               rootViewController: UIViewController(),
                               adTypes: [.native],
                               options: nil)
        self.adNativeLoader.delegate = self
        self.adNativeLoader.load(GADRequest())
    }
    
    func isExist() -> Bool {
        return self.nativeAd != nil
    }
    
    public func getAd() -> GADNativeAd? {
        return self.nativeAd
    }
    
    public func setConfigData(didLoadAd: (() -> ())?) {
        self.configData = didLoadAd
    }
}

extension NativeAd: GADNativeAdLoaderDelegate {
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        self.load()
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        self.nativeAd = nativeAd
        self.configData?()
    }
}
