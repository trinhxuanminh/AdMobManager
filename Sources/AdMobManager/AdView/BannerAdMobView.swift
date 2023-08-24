//
//  BannerAdMobView.swift
//  AdMobManager
//
//  Created by Trịnh Xuân Minh on 25/03/2022.
//

import UIKit
import GoogleMobileAds

/// This class returns a UIView displaying BannerAd.
/// ```
/// import AdMobManager
/// ```
/// Ad display is automatic.
/// - Warning: Ad will not be displayed without adding ID.
open class BannerAdMobView: UIView {
  private lazy var bannerAdView: GADBannerView! = {
    let bannerView = GADBannerView()
    bannerView.translatesAutoresizingMaskIntoConstraints = false
    return bannerView
  }()
  
  public enum Anchored: String {
    case top
    case bottom
  }
  
  private var isLoading = false
  private var adUnitID: String?
  private var isExist = false
  private var anchored: Anchored?
  private var didReceive: Handler?
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    addComponents()
    setConstraints()
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    addComponents()
    setConstraints()
  }

  required public init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  public override func removeFromSuperview() {
    self.bannerAdView = nil
    super.removeFromSuperview()
  }
  
  func addComponents() {
    addSubview(bannerAdView)
  }
  
  func setConstraints() {
    let constraints = [
      bannerAdView.topAnchor.constraint(equalTo: self.topAnchor),
      bannerAdView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
      bannerAdView.leftAnchor.constraint(equalTo: self.leftAnchor),
      bannerAdView.rightAnchor.constraint(equalTo: self.rightAnchor)
    ]
    NSLayoutConstraint.activate(constraints)
  }
  
  public func load(name: String) {
    guard adUnitID == nil else {
      return
    }
    guard let ad = AdMobManager.shared.getOnceUsedAd(type: .banner, name: name) as? Banner else {
      return
    }
    self.adUnitID = ad.id
    if let anchored = ad.anchored {
      self.anchored = Anchored(rawValue: anchored)
    }
    load()
  }
  
  public func binding(didReceive: @escaping Handler) {
    self.didReceive = didReceive
  }
}

extension BannerAdMobView: GADBannerViewDelegate {
  public func bannerView(_ bannerView: GADBannerView,
                         didFailToReceiveAdWithError error: Error
  ) {
    self.isLoading = false
  }
  
  public func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
    print("AdMobManager: BannerAd did load!")
    isExist = true
    didReceive?()
  }
}

extension BannerAdMobView {
  private func load() {
    guard !isLoading else {
      return
    }
    
    guard !isExist else {
      return
    }
    
    guard let adUnitID = adUnitID else {
      print("AdMobManager: BannerAd failed to load - not initialized yet! Please install ID.")
      return
    }
    
    DispatchQueue.main.async { [weak self] in
      guard let self = self else {
        return
      }
      guard let rootViewController = UIApplication.topStackViewController() else {
        print("AdMobManager: BannerAd display failure - can't find RootViewController!")
        return
      }
      
      self.isLoading = true
      print("AdMobManager: BannerAd start load!")
      self.bannerAdView?.adUnitID = adUnitID
      self.bannerAdView?.delegate = self
      self.bannerAdView?.rootViewController = rootViewController
      
      let request = GADRequest()
      
      if let anchored = self.anchored {
        let extras = GADExtras()
        extras.additionalParameters = ["collapsible": anchored.rawValue]
        request.register(extras)
      }
      
      self.bannerAdView?.load(request)
    }
  }
}
