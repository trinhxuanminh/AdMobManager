//
//  NativeAdView.swift
//  AdMobManager
//
//  Created by Trịnh Xuân Minh on 27/03/2022.
//

import UIKit
import GoogleMobileAds
import NVActivityIndicatorView

/// This class returns a UIView displaying NativeAd.
/// ```
/// import AdMobManager
/// ```
/// Can be instantiated programmatically or Interface Builder. Use as UIView. Ad display is automatic.
/// Minimum height is **100**
/// - Warning: Native Ad will not be displayed without adding ID.
@IBDesignable public class NativeAdView: UIView {

    /// This constant returns the minimum recommended height for NativeAdView.
    public static let adHeightMinimum: CGFloat = 100
    
    @IBOutlet var contentView: UIView!
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
    
    fileprivate var listNativeAd: [NativeAd?] = [NativeAd()]
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setupView()
        self.createComponents()
        self.setupConstraints()
        self.setAd()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
        self.createComponents()
        self.setupConstraints()
        self.setAd()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public override func removeFromSuperview() {
        for index in 0..<self.listNativeAd.count {
            self.listNativeAd[index] = nil
        }
        super.removeFromSuperview()
    }
    
    /// This function helps to adjust the color of the ad content.
    /// - Parameter style: Change the color of the labels according to the interface style. Default is **light**.
    /// - Parameter backgroundColor: Change background color of NativeAdView class. Default is **clear**.
    /// - Parameter themeColor: Change the background color of the buttons. Default is **#87A605**.
    public func set_Color(style: AdMobManager.Style? = nil, backgroundColor: UIColor? = nil, themeColor: UIColor? = nil) {
        if let style = style {
            switch style {
            case .dark:
                self.headlineLabel?.textColor = UIColor(rgb: 0xFFFFFF)
                
                self.adLabel?.textColor = UIColor(rgb: 0xFFFFFF)
                self.adLabel?.backgroundColor = UIColor(rgb: 0x004AFF)
                
                self.advertiserLabel?.textColor = UIColor(rgb: 0xFFFFFF, alpha: 0.6)
                
                self.callToActionButton?.setTitleColor(UIColor(rgb: 0x000000), for: .normal)
                
                if ((self.loadingIndicator?.isAnimating) != nil) {
                    self.loadingIndicator?.stopAnimating()
                    self.loadingIndicator?.color = UIColor(rgb: 0xFFFFFF)
                    self.loadingIndicator?.startAnimating()
                } else {
                    self.loadingIndicator?.color = UIColor(rgb: 0xFFFFFF)
                }
            case .light:
                self.headlineLabel?.textColor = UIColor(rgb: 0x000000)
                
                self.adLabel?.textColor = UIColor(rgb: 0x000000)
                self.adLabel?.backgroundColor = UIColor(rgb: 0xFFB500)
                
                self.advertiserLabel?.textColor = UIColor(rgb: 0x000000, alpha: 0.6)
                
                self.callToActionButton?.setTitleColor(UIColor(rgb: 0xFFFFFF), for: .normal)
                
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
            self.contentView?.backgroundColor = backgroundColor
        }
        
        if let themeColor = themeColor {
            self.callToActionButton?.backgroundColor = themeColor
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
    
    /// This function helps to change the ads in the cell.
    /// - Parameter index: Index of ads to show in the list.
    public func setAd(index: Int = 0) {
        if index < 0 {
            return
        }
        if index >= self.listNativeAd.count {
            for _ in self.listNativeAd.count..<index {
                self.listNativeAd.append(nil)
            }
            self.listNativeAd.append(NativeAd())
        }
        if self.listNativeAd[index] == nil {
            self.listNativeAd[index] = NativeAd()
        }
        self.config_Data(ad: self.listNativeAd[index]?.nativeAd)
        self.listNativeAd[index]?.configData = { [weak self] in
            self?.config_Data(ad: self?.listNativeAd[index]?.nativeAd)
        }
    }
}

extension NativeAdView {
    func createComponents() {
        self.loadingIndicator = NVActivityIndicatorView(frame: .zero)
        self.contentView.addSubview(self.loadingIndicator)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            self.loadingIndicator.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            self.loadingIndicator.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            self.loadingIndicator.widthAnchor.constraint(equalToConstant: 20),
            self.loadingIndicator.heightAnchor.constraint(equalToConstant: 20),
        ])
    }
    
    func setupView() {
        Bundle.module.loadNibNamed(NativeAdView.className, owner: self, options: nil)
        self.addSubview(self.contentView)
        self.contentView.frame = self.bounds
        self.contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    func config_Data(ad: GADNativeAd?) {
        guard let nativeAd = ad else {
            self.loadingIndicator?.startAnimating()
            self.nativeAdView?.isHidden = true
            return
        }
        
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
