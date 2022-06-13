//
//  BannerAdView.swift
//  AdMobManager
//
//  Created by Trịnh Xuân Minh on 25/03/2022.
//

import Foundation
import UIKit
import GoogleMobileAds
import NVActivityIndicatorView

/// This class returns a UIView displaying BannerAd.
/// ```
/// import AdMobManager
/// ```
/// Can be instantiated programmatically or Interface Builder. Use as UIView. Ad display is automatic.
/// - Warning: Banner Ad will not be displayed without adding ID.
@IBDesignable public class BannerAdView: UIView {
    
    fileprivate var bannerAdView: GADBannerView! {
        didSet {
            self.bannerAdView?.translatesAutoresizingMaskIntoConstraints = false
            self.bannerAdView?.isHidden = true
        }
    }
    fileprivate var loadingIndicator: NVActivityIndicatorView! {
        didSet {
            self.loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
            self.loadingIndicator.type = .ballPulse
            self.loadingIndicator.padding = 30
            self.loadingIndicator.color = UIColor(rgb: 0x000000)
            self.loadingIndicator.startAnimating()
        }
    }
    
    fileprivate var adUnit_ID: String?
    fileprivate var isLoading: Bool = false
    fileprivate var isExist: Bool = false
    fileprivate var didFirstLoadAd: Bool = false
    
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
            self.request()
        }
    }
    
    public override func removeFromSuperview() {
        self.bannerAdView = nil
        super.removeFromSuperview()
    }
    
    /// This function helps to adjust the color of the ad content.
    /// - Parameter style: Change the color of Activity Indicator according to the interface style. Default is **light**.
    /// - Parameter backgroundColor: Change background color of BannerAdView class. Default is **clear**.
    public func set_Color(style: AdMobManager.Style? = nil, backgroundColor: UIColor? = nil) {
        if let style = style {
            switch style {
            case .dark:
                if ((self.loadingIndicator?.isAnimating) != nil) {
                    self.loadingIndicator?.stopAnimating()
                    self.loadingIndicator?.color = UIColor(rgb: 0xFFFFFF)
                    self.loadingIndicator?.startAnimating()
                } else {
                    self.loadingIndicator?.color = UIColor(rgb: 0xFFFFFF)
                }
            case .light:
                if ((self.loadingIndicator?.isAnimating) != nil) {
                    self.loadingIndicator?.stopAnimating()
                    self.loadingIndicator?.color = UIColor(rgb: 0x000000)
                    self.loadingIndicator?.startAnimating()
                } else {
                    self.loadingIndicator?.color = UIColor(rgb: 0x000000)
                }
            }
        }
        
        if let backgroundColor = backgroundColor {
            self.backgroundColor = backgroundColor
        }
    }
    
    /// This function helps to change the loading type.
    /// - Parameter type: The NVActivityIndicatorType want to display. Default is **ballPulse**.
    public func set_Loading_Type(type: NVActivityIndicatorType) {
        if ((self.loadingIndicator?.isAnimating) != nil) {
            self.loadingIndicator?.stopAnimating()
            self.loadingIndicator?.type = type
            self.loadingIndicator?.startAnimating()
        } else {
            self.loadingIndicator?.type = type
        }
    }
    
    func load() {
        if self.isLoading {
            return
        }
        
        if self.isExist {
            return
        }
        
        if #available(iOS 12.0, *), !NetworkMonitor.shared.isConnected {
            print("Not connected!")
            self.request()
            return
        }
        
        guard let adUnit_ID = self.adUnit_ID else {
            print("No BannerAd ID!")
            return
        }

        guard let rootViewController = UIApplication.topStackViewController() else {
            print("Can't find RootViewController!")
            return
        }
        
        self.isLoading = true

        self.bannerAdView?.adUnitID = adUnit_ID
        self.bannerAdView?.delegate = self
        self.bannerAdView?.rootViewController = rootViewController
        self.bannerAdView?.load(GADRequest())
    }
    
    func request() {
        let adReloadTime: Double = AdMobManager.shared.getAdReloadTime()
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int(adReloadTime * 1000)), execute: self.load)
    }
}

extension BannerAdView: GADBannerViewDelegate {
    public func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("BannerAd download error, trying again!")
        self.isLoading = false
    }

    public func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        self.isExist = true
        self.bannerAdView?.isHidden = false
        self.loadingIndicator?.stopAnimating()
        self.loadingIndicator?.isHidden = true
    }
}

extension BannerAdView {
    func createComponents() {
        self.loadingIndicator = NVActivityIndicatorView(frame: .zero)
        self.addSubview(self.loadingIndicator)
        
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
        
        NSLayoutConstraint.activate([
            self.loadingIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.loadingIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.loadingIndicator.widthAnchor.constraint(equalToConstant: 20),
            self.loadingIndicator.heightAnchor.constraint(equalToConstant: 20),
        ])
    }
}
