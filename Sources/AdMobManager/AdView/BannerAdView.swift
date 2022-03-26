//
//  File.swift
//  
//
//  Created by Trịnh Xuân Minh on 26/03/2022.
//

import Foundation
import UIKit
import GoogleMobileAds

public class BannerAdView: GADBannerView {
    
    fileprivate var adUnit_ID: String?
    fileprivate var isLoading: Bool = false
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        self.adUnit_ID = AdMobManager.shared.getBannerAdID()
        self.load()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.adUnit_ID = AdMobManager.shared.getBannerAdID()
        self.load()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func load() {
        if self.isLoading {
            return
        }
        
        guard let adUnit_ID = adUnit_ID else {
            print("No BannerAd ID!")
            return
        }
        
        guard let topViewController = UIApplication.topStackViewController() else {
            print("Can't find RootViewController!")
            return
        }
        
        self.isLoading = true
        
        self.adUnit_ID = adUnit_ID
        self.rootViewController = topViewController
        self.load(GADRequest())
    }
}

extension BannerAdView: GADBannerViewDelegate {
    public func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        self.isLoading = false
        self.load()
    }
}
