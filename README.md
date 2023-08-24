# AdMobManager

A package to help support the implementation of ads on your **iOS** app.
- For Swift 5.3, Xcode 12.5 (macOS Big Sur) or later.
- Support for apps from iOS 13.0 or newer.

## Ad Type
- InterstitialAd
- RewardedAd
- RewardedInterstitialAd
- AppOpenAd
- NativeAd
- BannerAd

## Installation

### Swift Package Manager

The Swift Package Manager is a tool for managing the distribution of **Swift** code. To use `AdMobManager` with Swift Package Manger, add it to dependencies in your `Package.swift`.
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

Integrate Firebase RemoteConfig with any `Key name` and configure it in [this json format](https://github.com/trinhxuanminh/AdMobManager/blob/main/Sources/AdMobManager/Template/RegistrationStructure.strings).
**Note**: The name of each ad is unique.

## Demo
Refer to the following [Demo project](https://github.com/trinhxuanminh/DemoAdMobManager) to implement the ad.

## Usage
Firstly, import `AdMobManager`.
```swift
import AdMobManager
```

### 1. Parameter setting

#### Register advertising ID
```swift
AdMobManager.shared.register(remoteKey: String, completed: Handler?)
```
- remoteKey: The `Key name` you have set on RemoteConfig.
- completed: The block executes after the ad has successfully registered. If you need to load ads as soon as you open the app, you should call the load function here.

### 2. Control

#### isRegisterSuccessfully()
This function returns the value _**true/false**_ indicating whether the ad was successfully registered or not.
```swift
AdMobManager.shared.isRegisterSuccessfully() -> Bool
```

#### status()
This function returns the value _**true/false**_ indicating whether the ad is allowed to show. You can call it to make UI changes, logic in your code.
- Returns _**nil**_ when registration is not successful or there is no ad with the corresponding name.
```swift
AdMobManager.shared.status(type: AdType, name: String) -> Bool?
```

#### load()
This function will start loading ads.
```swift
AdMobManager.shared.load(type: Reuse, name: String)
```

#### isReady()
This function returns a value _**true/false**_ indicating if the ad is ready to be displayed.
- Returns _**nil**_ when there is no advertisement with the corresponding name.
```swift
AdMobManager.shared.isReady(name: String) -> Bool?
```

#### show()
This function will display ads when ready.

##### Parameters:
- willPresent: The block executes after the ad is about to show.
- willDismiss: The block executes after the ad is about to disappear.
- didDismiss: The block executes after the ad has disappeared.
- didFail: The block executes after the ad failed to display the content.

```swift
AdMobManager.shared.show(name: String)
```

### 3. NativeAd
- Download & add file [`CustomNativeAdView.xib`](https://github.com/trinhxuanminh/AdMobManager/blob/main/Sources/AdMobManager/Template/CustomNativeAdView.xib).
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
    load(name: String)
  }
}
```
- Ads will be loaded automatically.
- Call `binding` method to display ads when loading successfully.

### 4. BannerAd
Ads will be loaded automatically.
Then, there are two ways you can create `BannerAdMobView`:
- By storyboard, changing class of any `UIView` to `BannerAdMobView`. _**Note**: Set `Module` to `AdMobManager`._
- By code, using initializer.

```swift
bannerAdMobView.load(name: String)
```

## License
### [ProX Global](https://proxglobal.com)
### Copyright (c) Trịnh Xuân Minh 2022 [@trinhxuanminh](minhtx@proxglobal.com)
