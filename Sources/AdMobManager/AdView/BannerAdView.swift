//
//  File.swift
//  
//
//  Created by Trịnh Xuân Minh on 26/03/2022.
//

import Foundation
import UIKit
import GoogleMobileAds

public class BannerAdView: UIView {
    
    fileprivate var bannerAdView: GADBannerView! {
        didSet {
            self.bannerAdView.translatesAutoresizingMaskIntoConstraints = false
            self.adUnit_ID = AdMobManager.shared.getBannerAdID()
            self.bannerAdView.backgroundColor = .red
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
        fatalError("init(coder:) has not been implemented")
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
        
        self.adUnit_ID = adUnit_ID
        self.bannerAdView.rootViewController = topViewController
        self.bannerAdView.load(GADRequest())
    }
}

extension BannerAdView: GADBannerViewDelegate {
    public func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        self.isLoading = false
        self.load()
    }
    
    public func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("did load ad")
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
