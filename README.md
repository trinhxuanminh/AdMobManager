# AdMobManager

A package to help support the implementation of ads on your **iOS** app.
- For Swift 5.3, Xcode 12.0 (macOS Big Sur) or later.
- Support for apps from iOS 10.0 or newer.

## Ad Type
- SplashAd
- InterstitialAd
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

Set the _-ObjC_ linker flag at `Info.plist`:
```swift
<key>GADIsAdManagerApp</key>
  <true/>
```

## Usage
Firstly, import `AdMobManager`.
```swift
import AdMobManager
```

### 1. Parameter setting

#### Advertising ID
This function helps to change the ad ID, available for the next load.
- Ad parameters is nil will not load the corresponding ad type.
```swift
AdMobManager.shared.setID(
  splash: String?,
  interstitial: String?,
  appOpen: String?,
  native: String?,
  banner: String?)
```

#### Deployment Time (Optional)
This function helps to set the date to start showing ads.
- Default is _**nil**_, the ad will be displayed as soon as it is ready.
- Changes only for `SplashAd`, `InterstitialAd`, `AppOpenAd`.
```swift
AdMobManager.shared.showFullFeature(from: Date)
```

#### Time between (Optional)
This function helps to change the minimum display time between ads of the same type.
- Default is _**5 seconds**_.
- Changes only for `InterstitialAd`, `AppOpenAd`.
```swift
AdMobManager.shared.setTimeBetween(_ time: Double, ad type: ReuseAdType)
```

### 2. Control

#### isReady()
This function returns a value _**true/false**_ indicating if the ad is ready to be displayed.
```swift
AdMobManager.shared.isReady(ad type: AdType)
```

#### show()
This function will display ads when ready.

##### Parameters:
- willPresent: The block executes after the ad is about to show.
- willDismiss: The block executes after the ad is about to disappear.
- didDismiss: The block executes after the ad has disappeared.

```swift
AdMobManager.shared.show(ad type: AdType)
```

### 3. NativeAd
Ads are displayed automatically.

#### **a) NativeAdCollectionViewCell / NativeAdvancedAdCollectionViewCell**
This class returns a UICollectionViewCell displaying NativeAd.

##### Register
```swift
collectionView.registerAds(ofType: NativeAdCollectionViewCell.self)
```
```swift
collectionView.registerAds(ofType: NativeAdvancedAdCollectionViewCell.self)
```

##### Datasource
```swift
func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
  let collectionViewCell = collectionView.dequeueCell(ofType: NativeAdCollectionViewCell.self, indexPath: indexPath)
//            Optional
  return collectionViewCell
}
```
```swift
func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
  let collectionViewCell = collectionView.dequeueCell(ofType: NativeAdvancedAdCollectionViewCell.self, indexPath: indexPath)
//            Optional
  return collectionViewCell
}
```

#### **b) NativeAdTableViewCell / NativeAdvancedAdTableViewCell**
This class returns a UITableViewCell displaying NativeAd.

##### Register
```swift
tableView.registerAds(ofType: NativeAdTableViewCell.self)
```
```swift
tableView.registerAds(ofType: NativeAdvancedAdTableViewCell.self)
```

##### Datasource
```swift
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
  let tableViewCell = tableView.dequeueCell(ofType: NativeAdTableViewCell.self, indexPath: indexPath)
//            Optional
  return tableViewCell
}
```
```swift
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
  let tableViewCell = tableView.dequeueCell(ofType: NativeAdvancedAdTableViewCell.self, indexPath: indexPath)
//            Optional
  return tableViewCell
}
```

#### **c) NativeAdView / NativeAdvancedAdView**
Then, there are two ways you can create `NativeAdView` / `NativeAdvancedAdView`:
- By storyboard, changing class of any `UIView` to `NativeAdView` / `NativeAdvancedAdView`. _**Note**: Set `Module` to `AdMobManager`._
- By code, using initializer.

#### **d) Determine the height**

```swift
NativeAdCollectionViewCell.adHeightMinimum()
```
```swift
NativeAdvancedAdTableViewCell.adHeightMinimum(width: tableView.frame.width)
```

#### **e) Optional**
```swift
.setAd(index: Int = 0)
```
```swift
.setInterface(style: AdMobManager.Style)
```
```swift
.setTheme(color: UIColor)
```
```swift
.setAnimatedColor(base: UIColor? = nil, secondary: UIColor? = nil)
```

### 4. BannerAd
Ads are displayed automatically.
Then, there are two ways you can create `BannerAdView`:
- By storyboard, changing class of any `UIView` to `BannerAdView`. _**Note**: Set `Module` to `AdMobManager`._
- By code, using initializer.

### 5. Error handling options

#### Limit reloading
This function helps to limit the reload of the ad when an error occurs.
- Time reload ads after failed load.
- Unit is milliseconds.
- Default is _**1000 milliseconds**_, ad will be reloaded immediately.
```swift
AdMobManager.shared.reloadingOfAds(after time: Double)
```
_**Note**: For iOS 11.4 and below, `InterstitialAd` and `AppOpenAd` will reload immediately after the failed impression._

#### Stop loading SplashAd
This function helps to block reloading of OnceAdType.
- Recommended when ads don’t need to appear anymore.
```swift
AdMobManager.shared.stopLoading(ad type: OnceAdType)
```

#### isConnected()
This function return about an value for know the path is available to establish connections and send data.
- Available for iOS 12.0 or newer.
```swift
AdMobManager.shared.isConnected()
```

## License
### [ProX Global](https://proxglobal.com)
### Copyright (c) Trịnh Xuân Minh 2022 [@trinhxuanminh](https://www.facebook.com/minhtx.developer)
