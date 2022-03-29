//
//  NativeAdTableViewCell.swift
//  AdMobManager
//
//  Created by Trịnh Xuân Minh on 28/03/2022.
//

import UIKit
import GoogleMobileAds
import NVActivityIndicatorView

/// This class returns a UITableViewCell displaying NativeAd.
/// ```
/// import AdMobManager
/// ```
/// ```
/// override func viewDidLoad() {
///     super.viewDidLoad()
///
///     self.tableView.register(UINib(nibName: NativeAdTableViewCell.className, bundle: AdMobManager.bundle), forCellReuseIdentifier: NativeAdTableViewCell.className)
/// }
/// ```
/// ```
/// func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
///     let cell = tableView.dequeueReusableCell(withIdentifier: NativeAdTableViewCell.className, for: indexPath) as! NativeAdTableViewCell
///     return cell
/// }
/// ```
/// Minimum height is **100**
/// - Warning: Native Ad will not be displayed without adding ID.
public class NativeAdTableViewCell: UITableViewCell {
    
    /// This constant returns the minimum recommended height for NativeAdTableViewCell.
    public static let adHeightMinimum: CGFloat = 100

    @IBOutlet weak var nativeAdView: GADNativeAdView!
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
    fileprivate var listNativeAd: [NativeAd?] = [NativeAd()]
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.createComponents()
        self.setupConstraints()
        self.setAd()
    }
    
    public override func removeFromSuperview() {
        for index in 0..<self.listNativeAd.count {
            self.listNativeAd[index] = nil
        }
        super.removeFromSuperview()
    }
    
    /// This function helps to adjust the color of the ad content.
    /// - Parameter style: Change the color of the labels according to the interface style. Default is **light**.
    /// - Parameter backgroundColor: Change background color of NativeAdTableViewCell class. Default is **clear**.
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
            self.contentView.backgroundColor = backgroundColor
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
        self.config_Data(ad: self.listNativeAd[index]?.get_Ad())
        self.listNativeAd[index]?.set_Config_Data { [weak self] in
            self?.config_Data(ad: self?.listNativeAd[index]?.get_Ad())
        }
    }
}

extension NativeAdTableViewCell {
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
