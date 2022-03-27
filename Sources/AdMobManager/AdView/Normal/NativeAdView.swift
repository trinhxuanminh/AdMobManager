//
//  NativeAdView.swift
//  
//
//  Created by Trịnh Xuân Minh on 27/03/2022.
//

import UIKit
import GoogleMobileAds
import NVActivityIndicatorView

@IBDesignable public class NativeAdView: UIView {

    /// This constant returns the minimum recommended height for NativeAdCollectionViewCell.
    public static let adHeightMinimum: CGFloat = 100

    @IBOutlet var nativeAdView: GADNativeAdView!
    @IBOutlet weak var headlineLabel: UILabel! {
        didSet {
            self.headlineLabel.textColor = UIColor(rgb: 0x000000)
        }
    }
    @IBOutlet weak var adLabel: UILabel! {
        didSet {
            self.adLabel.textColor = UIColor(rgb: 0x000000)
            self.adLabel.backgroundColor = UIColor(rgb: 0xFFB500)
        }
    }
    @IBOutlet weak var advertiserLabel: UILabel! {
        didSet {
            self.advertiserLabel.textColor = UIColor(rgb: 0x000000, alpha: 0.6)
        }
    }
    @IBOutlet weak var callToActionButton: UIButton! {
        didSet {
            self.callToActionButton.setTitleColor(UIColor(rgb: 0xFFFFFF), for: .normal)
            self.callToActionButton.backgroundColor = UIColor(rgb: 0x87A605)
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
    
    /// Interface style for ad content.
    public enum Style {
        /// This style will display white labels on a dark theme.
        case dark
        /// This style will display black labels on a dark theme.
        case light
    }
    
    fileprivate var didConfigData: Bool = false
    fileprivate var nativeAd: NativeAd = NativeAd()
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.createComponents()
        self.setupConstraints()
        self.setAd()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.createComponents()
        self.setupConstraints()
        self.setAd()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    /// This function helps to adjust the color of the ad content.
    /// - Parameter style: Change the color of the labels according to the interface style. Default is **light**.
    /// - Parameter backgroundColor: Change background color of NativeAdCollectionViewCell class. Default is **clear**.
    /// - Parameter themeColor: Change the background color of the buttons. Default is **#87A605**.
    public func set_Color(style: Style? = nil, backgroundColor: UIColor? = nil, themeColor: UIColor? = nil) {
        if let style = style {
            switch style {
            case .dark:
                self.headlineLabel.textColor = UIColor(rgb: 0xFFFFFF)
                
                self.adLabel.textColor = UIColor(rgb: 0xFFFFFF)
                self.adLabel.backgroundColor = UIColor(rgb: 0x004AFF)
                
                self.advertiserLabel.textColor = UIColor(rgb: 0xFFFFFF, alpha: 0.6)
                
                self.callToActionButton.setTitleColor(UIColor(rgb: 0x000000), for: .normal)
                
                if self.loadingIndicator.isAnimating {
                    self.loadingIndicator.stopAnimating()
                    self.loadingIndicator.color = UIColor(rgb: 0xFFFFFF)
                    self.loadingIndicator.startAnimating()
                } else {
                    self.loadingIndicator.color = UIColor(rgb: 0xFFFFFF)
                }
            case .light:
                self.headlineLabel.textColor = UIColor(rgb: 0x000000)
                
                self.adLabel.textColor = UIColor(rgb: 0x000000)
                self.adLabel.backgroundColor = UIColor(rgb: 0xFFB500)
                
                self.advertiserLabel.textColor = UIColor(rgb: 0x000000, alpha: 0.6)
                
                self.callToActionButton.setTitleColor(UIColor(rgb: 0xFFFFFF), for: .normal)
                
                if self.loadingIndicator.isAnimating {
                    self.loadingIndicator.stopAnimating()
                    self.loadingIndicator.color = UIColor(rgb: 0x000000)
                    self.loadingIndicator.startAnimating()
                } else {
                    self.loadingIndicator.color = UIColor(rgb: 0x000000)
                }
            }
        }
        
        if let backgroundColor = backgroundColor {
            self.backgroundColor = backgroundColor
        }
        
        if let themeColor = themeColor {
            self.callToActionButton.backgroundColor = themeColor
        }
    }
    
    /// This function helps to change the loading type.
    /// - Parameter type: The NVActivityIndicatorType want to display. Default is **ballPulse**.
    public func set_Loading_Type(type: NVActivityIndicatorType) {
        if self.loadingIndicator.isAnimating {
            self.loadingIndicator.stopAnimating()
            self.loadingIndicator.type = type
            self.loadingIndicator.startAnimating()
        } else {
            self.loadingIndicator.type = type
        }
    }
}

extension NativeAdView {
    func createComponents() {
        self.loadingIndicator = NVActivityIndicatorView(frame: .zero)
        self.addSubview(self.loadingIndicator)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            self.loadingIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.loadingIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.loadingIndicator.widthAnchor.constraint(equalToConstant: 20),
            self.loadingIndicator.heightAnchor.constraint(equalToConstant: 20),
        ])
    }
    
    func setAd() {
        self.config_Data(ad: self.nativeAd.get_Ad())
        self.nativeAd.set_Config_Data {
            self.config_Data(ad: self.nativeAd.get_Ad())
        }
    }
    
    func config_Data(ad: GADNativeAd?) {
        guard let nativeAd = ad else {
            self.loadingIndicator?.startAnimating()
            self.nativeAdView?.isHidden = true
            return
        }
        
        if self.didConfigData {
            return
        }
        
        self.didConfigData = true
        self.loadingIndicator?.stopAnimating()
        
        self.nativeAdView?.isHidden = false
        
        self.nativeAdView?.nativeAd = nativeAd
        
        (self.nativeAdView?.headlineView as? UILabel)?.text = nativeAd.headline

        (self.nativeAdView?.iconView as? UIImageView)?.image = nativeAd.icon?.image

        (self.nativeAdView?.advertiserView as? UILabel)?.text = nativeAd.advertiser
        self.nativeAdView?.advertiserView?.isHidden = nativeAd.advertiser == nil
        
        (self.nativeAdView?.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        self.nativeAdView?.callToActionView?.isHidden = nativeAd.callToAction == nil
        
        // In order for the SDK to process touch events properly, user interaction should be disabled.
        self.nativeAdView?.callToActionView?.isUserInteractionEnabled = false
    }
}
