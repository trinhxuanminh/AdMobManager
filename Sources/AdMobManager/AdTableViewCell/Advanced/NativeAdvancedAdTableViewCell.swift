//
//  NativeAdvancedAdTableViewCell.swift
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
///     self.tableView.register(UINib(nibName: NativeAdvancedAdTableViewCell.className, bundle: AdMobManager.bundle), forCellReuseIdentifier: NativeAdvancedAdTableViewCell.className)
/// }
/// ```
/// ```
/// func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
///     let cell = tableView.dequeueReusableCell(withIdentifier: NativeAdvancedAdTableViewCell.className, for: indexPath) as! NativeAdvancedAdTableViewCell
///     return cell
/// }
/// ```
/// Minimum height is **400**
/// - Warning: Native Ad will not be displayed without adding ID.
public class NativeAdvancedAdTableViewCell: UITableViewCell, GADVideoControllerDelegate {
    
    /// This constant returns the minimum recommended height for NativeAdvancedAdTableViewCell.
    public static let adHeightMinimum: CGFloat = 400
    
    @IBOutlet weak var callToActionButton: UIButton! {
        didSet {
            self.callToActionButton.setTitleColor(UIColor(rgb: 0x87A605), for: .normal)
        }
    }
    @IBOutlet weak var storeLabel: UILabel! {
        didSet {
            self.storeLabel.textColor = UIColor(rgb: 0x000000)
        }
    }
    @IBOutlet weak var priceLabel: UILabel! {
        didSet {
            self.priceLabel.textColor = UIColor(rgb: 0x000000)
        }
    }
    @IBOutlet weak var bodyLabel: UILabel! {
        didSet {
            self.bodyLabel.textColor = UIColor(rgb: 0x000000)
        }
    }
    @IBOutlet weak var advertiserLabel: UILabel! {
        didSet {
            self.advertiserLabel.textColor = UIColor(rgb: 0x000000, alpha: 0.6)
        }
    }
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
    @IBOutlet weak var nativeAdView: GADNativeAdView! {
        didSet {
            self.nativeAdView.layer.borderWidth = 1.0
            self.nativeAdView.layer.borderColor = UIColor(rgb: 0x87A605).cgColor
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
//    fileprivate var nativeAd: NativeAd = NativeAd()
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.createComponents()
        self.setupConstraints()
//        self.setAd()
    }
    
    /// This function helps to adjust the color of the ad content.
    /// - Parameter style: Change the color of the labels according to the interface style. Default is **light**.
    /// - Parameter backgroundColor: Change background color of NativeAdvancedAdTableViewCell class. Default is **clear**.
    /// - Parameter themeColor: Change the title color of the buttons and the border color. Default is **#87A605**.
    public func set_Color(style: Style? = nil, backgroundColor: UIColor? = nil, themeColor: UIColor? = nil) {
        if let style = style {
            switch style {
            case .dark:
                self.headlineLabel.textColor = UIColor(rgb: 0xFFFFFF)
                
                self.adLabel.textColor = UIColor(rgb: 0xFFFFFF)
                self.adLabel.backgroundColor = UIColor(rgb: 0x004AFF)
                
                self.advertiserLabel.textColor = UIColor(rgb: 0xFFFFFF, alpha: 0.6)
                
                self.storeLabel.textColor = UIColor(rgb: 0xFFFFFF)
                
                self.priceLabel.textColor = UIColor(rgb: 0xFFFFFF)
                
                self.bodyLabel.textColor = UIColor(rgb: 0xFFFFFF)
                
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
                
                self.storeLabel.textColor = UIColor(rgb: 0x000000)
                
                self.priceLabel.textColor = UIColor(rgb: 0x000000)
                
                self.bodyLabel.textColor = UIColor(rgb: 0x000000)
                
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
            self.nativeAdView.layer.borderColor = themeColor.cgColor
            self.callToActionButton.setTitleColor(themeColor, for: .normal)
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

extension NativeAdvancedAdTableViewCell {
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
    
//    func setAd() {
//        self.config_Data(ad: self.nativeAd.get_Ad())
//        self.nativeAd.set_Config_Data { [self] in
//            self.config_Data(ad: self.nativeAd.get_Ad())
//        }
//    }
    
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
        self.nativeAdView?.mediaView?.mediaContent = nativeAd.mediaContent

        let mediaContent = nativeAd.mediaContent
        if mediaContent.hasVideoContent {
            mediaContent.videoController.delegate = self
        }

        (self.nativeAdView?.bodyView as? UILabel)?.text = nativeAd.body
        self.nativeAdView?.bodyView?.isHidden = nativeAd.body == nil

        (self.nativeAdView?.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        self.nativeAdView?.callToActionView?.isHidden = nativeAd.callToAction == nil

        (self.nativeAdView?.iconView as? UIImageView)?.image = nativeAd.icon?.image
        self.nativeAdView?.iconView?.isHidden = nativeAd.icon == nil

        (self.nativeAdView?.starRatingView as? UIImageView)?.image = self.imageOfStars(from: nativeAd.starRating)
        self.nativeAdView?.starRatingView?.isHidden = nativeAd.starRating == nil

        (self.nativeAdView?.storeView as? UILabel)?.text = nativeAd.store
        self.nativeAdView?.storeView?.isHidden = nativeAd.store == nil

        (self.nativeAdView?.priceView as? UILabel)?.text = nativeAd.price
        self.nativeAdView?.priceView?.isHidden = nativeAd.price == nil

        (self.nativeAdView?.advertiserView as? UILabel)?.text = nativeAd.advertiser
        self.nativeAdView?.advertiserView?.isHidden = nativeAd.advertiser == nil

        self.nativeAdView?.callToActionView?.isUserInteractionEnabled = false
    }
    
    func imageOfStars(from starRating: NSDecimalNumber?) -> UIImage? {
        guard let rating = starRating?.doubleValue else {
            return nil
        }
        var imageName: String?
        
        if rating >= 5 {
            imageName = "stars_5"
        } else if rating >= 4.5 {
            imageName = "stars_4_5"
        } else if rating >= 4 {
            imageName = "stars_4"
        } else if rating >= 3.5 {
            imageName = "stars_3_5"
        }
        
        if let imageName = imageName, let path = Bundle.module.path(forResource: imageName, ofType: "png"), let image = UIImage(contentsOfFile: path) {
            return image
        } else {
            return nil
        }
    }
}
