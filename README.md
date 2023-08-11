# AdMobManager

A package to help support the implementation of ads on your **iOS** app.
- For Swift 5.3, Xcode 12.5 (macOS Big Sur) or later.
- Support for apps from iOS 12.0 or newer.

## Ad Type
- InterstitialAd
- RewardedAd
- RewardedInterstitialAd
- AppOpenAd
- NativeAd
- BannerAd

## Installation

### Swift Package Manager

The Swift Package Manager is a tool for managing the distribution of **Swift** code. To use AdMobManager with Swift Package Manger, add it to dependencies in your Package.swift
```swift
  dependencies: [
    .package(url: "https://github.com/trinhxuanminh/AdMobManager.git")
]
```

## Get started

Initial setup as documented by _Google AdMob_:
- [Update your Info.plist](https://developers.google.com/admob/ios/quick-start?hl=vi#update_your_infoplist)
- [Initialize the Mobile Ads SDK](https://developers.google.com/admob/ios/quick-start?hl=vi#initialize_the_mobile_ads_sdk)

Manually add the `-ObjC` linker flag to `Other Linker Flags` in your target's build settings:
- Select target project.
- Select tab `All`, find `Other Linker Flags`.
- You must set the `-ObjC` flag for both the `Debug` and `Release` configurations.

**Note**: If you have Firebase, install [it](https://github.com/firebase/firebase-ios-sdk) using Swift Package Manager to avoid conflicts.

## Usage
Firstly, import `AdMobManager`.
```swift
import AdMobManager
```

### 1. Parameter setting

#### Advertising ID
This function helps to register ads by unique key.
```swift
AdMobManager.shared.register(key: String, type: AdType, id: String)
```

#### Time between (Optional)
This function helps to change the minimum display time between ads of the same type.
- Default is _**0 seconds**_.
```swift
AdMobManager.shared.setTimeBetween(key: String, time: Double)
```

### 2. Control

#### isReady()
This function returns a value _**true/false**_ indicating if the ad is ready to be displayed.
- Returns _**nil**_ when there is no advertisement with the corresponding key.
```swift
AdMobManager.shared.isReady(key: String) -> Bool?
```

#### show()
This function will display ads when ready.

##### Parameters:
- willPresent: The block executes after the ad is about to show.
- willDismiss: The block executes after the ad is about to disappear.
- didDismiss: The block executes after the ad has disappeared.
- didFail: The block executes after the ad failed to display the content.

```swift
AdMobManager.shared.show(key: String)
```

### 3. NativeAd
- Download & add file [`CustomNativeAdView.xib`](https://github.com/trinhxuanminh/AdMobManager/blob/main/Sources/AdMobManager/AdView/CustomNativeAdView.xib).
**Note**: Linked outlets to views, update constraints only.
- Create the corresponding `File's owner`, inherit `NativeAdMobView`.
```swift
class CustomNativeAdView: NativeAdMobView {
  override func setProperties() {
    startAnimation()
    binding(nativeAdView: nativeAdView) { [weak self] in
      guard let self = self else {
        return
      }
      self.stopAnimation()
    }
    register(id: "ca-app-pub-3940256099942544/3986624511", isFullScreen: false)
  }
}
```
- Ads will be loaded automatically.
- Call `binding` method to display ads when loading successfully.
- Call `register` method to load ads.

### 4. BannerAd
Ads will be loaded automatically.
Then, there are two ways you can create `BannerAdMobView`:
- By storyboard, changing class of any `UIView` to `BannerAdMobView`. _**Note**: Set `Module` to `AdMobManager`._
- By code, using initializer.

```swift
bannerAdMobView.register(id: "ca-app-pub-3940256099942544/2934735716",
                          collapsible: .top)
```

## License
### [ProX Global](https://proxglobal.com)
### Copyright (c) Trịnh Xuân Minh 2022 [@trinhxuanminh](minhtx@proxglobal.com)
