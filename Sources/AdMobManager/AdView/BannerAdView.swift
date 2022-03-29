//
//  BannerAdView.swift
//  AdMobManager
//
//  Created by Trịnh Xuân Minh on 25/03/2022.
//

import Foundation
import UIKit
import GoogleMobileAds

/// This class returns a UIView displaying BannerAd.
/// ```
/// import AdMobManager
/// ```
/// Can be instantiated programmatically or Interface Builder. Use as UIView. Ad display is automatic.
/// - Warning: Banner Ad will not be displayed without adding ID.
@IBDesignable public class BannerAdView: UIView {
    
    fileprivate var bannerAdView: GADBannerView! {
        didSet {
            self.bannerAdView.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    fileprivate var adUnit_ID: String?
    fileprivate var isLoading: Bool = false
    fileprivate var isExist: Bool = false
    fileprivate var didFirstLoadAd: Bool = false
    fileprivate var loadRequestWorkItem: DispatchWorkItem?
    fileprivate var rootViewController: UIViewController?
    
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
        
        if !self.didFirstLoadAd {
            self.didFirstLoadAd = true
            self.adUnit_ID = AdMobManager.shared.getBannerAdID()
            self.rootViewController = UIApplication.topStackViewController()
            self.request()
        }
    }
    
    public override func removeFromSuperview() {
        self.loadRequestWorkItem?.cancel()
        super.removeFromSuperview()
    }
    
    func load() {
        if self.isExist {
            return
        }
        
        guard let adUnit_ID = adUnit_ID else {
            print("No BannerAd ID!")
            return
        }
        
        guard let rootViewController = rootViewController else {
            print("Can't find RootViewController!")
            return
        }
        
        self.bannerAdView.adUnitID = adUnit_ID
        self.bannerAdView.delegate = self
        self.bannerAdView.rootViewController = rootViewController
        self.bannerAdView.load(GADRequest())
    }
    
    func request() {
        self.loadRequestWorkItem?.cancel()
        let requestWorkItem = DispatchWorkItem(block: self.load)
        self.loadRequestWorkItem = requestWorkItem
        let adReloadTime: Int? = AdMobManager.shared.getAdReloadTime()
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(adReloadTime == nil ? 0 : adReloadTime!), execute: requestWorkItem)
    }
}

extension BannerAdView: GADBannerViewDelegate {
    public func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("BannerAd download error, trying again!")
        self.request()
    }
    
    public func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        self.isExist = true
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
