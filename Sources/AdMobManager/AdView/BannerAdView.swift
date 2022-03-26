//
//  File.swift
//  
//
//  Created by Trịnh Xuân Minh on 26/03/2022.
//

import Foundation
import UIKit
import GoogleMobileAds

/// This class returns a UIView displaying BannerAd.
/// ```
/// import AdMobManager
/// ```
/// Can be instantiated by program or interface builder. Use as UIView. Ad display is automatic.
/// - Warning: Banner Ad will not be displayed without adding ID.
@IBDesignable public class BannerAdView: UIView {
    
    fileprivate var bannerAdView: GADBannerView! {
        didSet {
            self.bannerAdView.translatesAutoresizingMaskIntoConstraints = false
            self.adUnit_ID = AdMobManager.shared.getBannerAdID()
        }
    }
    
    fileprivate var adUnit_ID: String?
    fileprivate var isLoading: Bool = false
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        self.createComponents()
        self.setupConstraints()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.createComponents()
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.load()
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
        
        self.bannerAdView.adUnitID = adUnit_ID
        self.bannerAdView.delegate = self
        self.bannerAdView.rootViewController = topViewController
        self.bannerAdView.load(GADRequest())
    }
}

extension BannerAdView: GADBannerViewDelegate {
    public func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        self.isLoading = false
        print("BannerAd download error, trying again!")
        self.load()
    }
}

extension BannerAdView {
    func createComponents() {
        self.bannerAdView = GADBannerView()
        self.addSubview(self.bannerAdView)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            self.bannerAdView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.bannerAdView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.bannerAdView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.bannerAdView.topAnchor.constraint(equalTo: self.topAnchor)
        ])
    }
}
