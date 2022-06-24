////
////  NativeAdCollectionViewCell.swift
////  AdMobManager
////
////  Created by Trịnh Xuân Minh on 25/03/2022.
////
//
//import UIKit
//import GoogleMobileAds
//import NVActivityIndicatorView
//
///// This class returns a UICollectionViewCell displaying NativeAd.
///// ```
///// import AdMobManager
///// ```
///// ```
///// override func viewDidLoad() {
/////     super.viewDidLoad()
/////
/////     self.collectionView.register(UINib(nibName: NativeAdCollectionViewCell.className, bundle: AdMobManager.bundle), forCellWithReuseIdentifier: NativeAdCollectionViewCell.className)
///// }
///// ```
///// ```
///// func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
/////     let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NativeAdCollectionViewCell.className, for: indexPath) as! NativeAdCollectionViewCell
/////     return cell
///// }
///// ```
///// Minimum height is **100**
///// - Warning: Native Ad will not be displayed without adding ID.
//public class NativeAdCollectionViewCell: UICollectionViewCell {
//    
//    /// This constant returns the minimum recommended height for NativeAdCollectionViewCell.
//    public static let adHeightMinimum: CGFloat = 100
//
//    @IBOutlet var nativeAdView: GADNativeAdView!
//    @IBOutlet weak var headlineLabel: UILabel! {
//        didSet {
//            self.headlineLabel.textColor = UIColor(rgb: 0x000000)
//        }
//    }
//    @IBOutlet weak var adLabel: UILabel! {
//        didSet {
//            self.adLabel.textColor = UIColor(rgb: 0x000000)
//            self.adLabel.backgroundColor = UIColor(rgb: 0xFFB500)
//        }
//    }
//    @IBOutlet weak var advertiserLabel: UILabel! {
//        didSet {
//            self.advertiserLabel.textColor = UIColor(rgb: 0x000000, alpha: 0.6)
//        }
//    }
//    @IBOutlet weak var callToActionButton: UIButton! {
//        didSet {
//            self.callToActionButton.setTitleColor(UIColor(rgb: 0xFFFFFF), for: .normal)
//            self.callToActionButton.backgroundColor = UIColor(rgb: 0x87A605)
//        }
//    }
//    fileprivate var loadingIndicator: NVActivityIndicatorView! {
//        didSet {
//            self.loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
//            self.loadingIndicator.type = .ballPulse
//            self.loadingIndicator.padding = 30
//            self.loadingIndicator.color = UIColor(rgb: 0x000000)
//            self.loadingIndicator.startAnimating()
//        }
//    }
//    
//    fileprivate var listNativeAd: [NativeAd?] = [NativeAd()]
//    
//    public override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//        self.createComponents()
//        self.setupConstraints()
//        self.setAd()
//    }
//    
//    public override func removeFromSuperview() {
//        for index in 0..<self.listNativeAd.count {
//            self.listNativeAd[index] = nil
//        }
//        super.removeFromSuperview()
//    }
//    
//    /// This function helps to change the ads in the cell.
//    /// - Parameter index: Index of ads to show in the list.
//    public func setAd(index: Int = 0) {
//        if index < 0 {
//            return
//        }
//        if index >= self.listNativeAd.count {
//            for _ in self.listNativeAd.count..<index {
//                self.listNativeAd.append(nil)
//            }
//            self.listNativeAd.append(NativeAd())
//        }
//        if self.listNativeAd[index] == nil {
//            self.listNativeAd[index] = NativeAd()
//        }
//        self.config_Data(ad: self.listNativeAd[index]?.nativeAd)
//        self.listNativeAd[index]?.configData = { [weak self] in
//            self?.config_Data(ad: self?.listNativeAd[index]?.nativeAd)
//        }
//    }
//}
//
//extension NativeAdCollectionViewCell {
//    func createComponents() {
//        self.loadingIndicator = NVActivityIndicatorView(frame: .zero)
//        self.contentView.addSubview(self.loadingIndicator)
//    }
//    
//    func setupConstraints() {
//        NSLayoutConstraint.activate([
//            self.loadingIndicator.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
//            self.loadingIndicator.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
//            self.loadingIndicator.widthAnchor.constraint(equalToConstant: 20),
//            self.loadingIndicator.heightAnchor.constraint(equalToConstant: 20),
//        ])
//    }
//    
//    func config_Data(ad: GADNativeAd?) {
//        guard let nativeAd = ad else {
//            self.loadingIndicator?.startAnimating()
//            self.nativeAdView?.isHidden = true
//            return
//        }
//        
//        self.loadingIndicator?.stopAnimating()
//        
//        self.nativeAdView?.isHidden = false
//        
//        self.nativeAdView?.nativeAd = nativeAd
//        
//        (self.nativeAdView?.headlineView as? UILabel)?.text = nativeAd.headline
//
//        (self.nativeAdView?.iconView as? UIImageView)?.image = nativeAd.icon?.image
//
//        (self.nativeAdView?.advertiserView as? UILabel)?.text = nativeAd.advertiser
//        self.nativeAdView?.advertiserView?.isHidden = nativeAd.advertiser == nil
//        
//        (self.nativeAdView?.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
//        self.nativeAdView?.callToActionView?.isHidden = nativeAd.callToAction == nil
//        
//        // In order for the SDK to process touch events properly, user interaction should be disabled.
//        self.nativeAdView?.callToActionView?.isUserInteractionEnabled = false
//    }
//}
