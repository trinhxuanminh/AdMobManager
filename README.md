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
AdMobManager.shared.set_AdUnit(splashAd_ID: String?, interstitialAd_ID: String?, appOpenAd_ID: String?, nativeAd_ID: String?, bannerAd_ID: String?)
```

#### Deployment Time (Optional)
This function helps to set the date to start showing ads.
- Default is _**nil**_, the ad will be displayed as soon as it is ready.
- Changes only for `SplashAd`, `InterstitialAd`, `AppOpenAd`.
```swift
AdMobManager.shared.set_Time_Show_Full_Feature(start: Date)
```

#### Time between (Optional)
This function helps to change the minimum display time between ads of the same type.
- Default is _**5 seconds**_.
- Changes only for `InterstitialAd`, `AppOpenAd`.

##### e.g.
```swift
AdMobManager.shared.set_Time_Between(adType: AdMobManager.AdType, time: Double)
```

### 2. Control

#### is_Ready()
This function returns a value _**true/false**_ indicating if the ad is ready to be displayed.

##### e.g.
```swift
AdMobManager.shared.is_Ready(adType: AdMobManager.AdType)
```

#### show()
This function will display ads when ready.

##### Parameters:
- willPresent: The block executes after the ad is about to show.
- willDismiss: The block executes after the ad is about to disappear.
- didDismiss: The block executes after the ad has disappeared.

##### e.g.
```swift
AdMobManager.shared.show(adType: AdMobManager.AdType)
```

### 3. NativeAd
Ads are displayed automatically.

#### **a) NativeAdCollectionViewCell / NativeAdvancedAdCollectionViewCell**
This class returns a UICollectionViewCell displaying NativeAd.

##### Register
```swift
collectionView.register(UINib(nibName: NativeAdCollectionViewCell.className, bundle: AdMobManager.bundle), forCellWithReuseIdentifier: NativeAdCollectionViewCell.className)
```
```swift
collectionView.register(UINib(nibName: NativeAdvancedAdCollectionViewCell.className, bundle: AdMobManager.bundle), forCellWithReuseIdentifier: NativeAdvancedAdCollectionViewCell.className)
```

##### Datasource
```swift
func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let collectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: NativeAdCollectionViewCell.className, for: indexPath) as! NativeAdCollectionViewCell
//            Optional
    return collectionViewCell
}
```
```swift
func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let collectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: NativeAdvancedAdCollectionViewCell.className, for: indexPath) as! NativeAdvancedAdCollectionViewCell
//            Optional
    return collectionViewCell
}
```

#### **b) NativeAdTableViewCell / NativeAdvancedAdTableViewCell**
This class returns a UITableViewCell displaying NativeAd.

##### Register
```swift
tableView.register(UINib(nibName: NativeAdTableViewCell.className, bundle: AdMobManager.bundle), forCellReuseIdentifier: NativeAdTableViewCell.className)
```
```swift
tableView.register(UINib(nibName: NativeAdvancedAdTableViewCell.className, bundle: AdMobManager.bundle), forCellReuseIdentifier: NativeAdvancedAdTableViewCell.className)
```

##### Datasource
```swift
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let tableViewCell = tableView.dequeueReusableCell(withIdentifier: NativeAdTableViewCell.className, for: indexPath) as! NativeAdTableViewCell
//            Optional
    return tableViewCell
}
```
```swift
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let tableViewCell = tableView.dequeueReusableCell(withIdentifier: NativeAdvancedAdTableViewCell.className, for: indexPath) as! NativeAdvancedAdTableViewCell
//            Optional
    return tableViewCell
}
```

#### **c) NativeAdView / NativeAdvancedAdView**
Then, there are two ways you can create `NativeAdView` / `NativeAdvancedAdView`:
- By storyboard, changing class of any `UIView` to `NativeAdView` / `NativeAdvancedAdView`. _**Note**: Set `Module` to `AdMobManager`._
- By code, using initializer.

#### **d) Optional**
```swift
.set_Color(style: AdMobManager.Style?, backgroundColor: UIColor?, themeColor: UIColor?)
```
```swift
.set_Loading_Type(type: NVActivityIndicatorType)
```
```swift
.setAd(index: Int)
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
- Default is nil, ad will be reloaded immediately.
```swift
AdMobManager.shared.limit_Reloading_Of_Ads_When_There_Is_An_Error(adReloadTime: Int)
```

#### Stop loading SplashAd
This function helps to block reloading of SplashAd.
- Recommended when splash ads don’t need to appear anymore.
```swift
AdMobManager.shared.stop_Loading_SplashAd()
```

## License
### [ProX Global](https://proxglobal.com)
### Copyright (c) Trịnh Xuân Minh 2022 [@trinhxuanminh](https://www.facebook.com/minhtx.developer)
