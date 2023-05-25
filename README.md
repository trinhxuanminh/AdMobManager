# AdMobManager

A package to help support the implementation of ads on your **iOS** app.
- For Swift 5.3, Xcode 12.5 (macOS Big Sur) or later.
- Support for apps from iOS 10.0 or newer.

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

Set the _-ObjC_ linker flag at `Info.plist`:
```swift
<key>GADIsAdManagerApp</key>
  <true/>
```

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

#### Deployment Time (Optional)
This function helps to set the date to start showing ads.
- Default is _**nil**_, the ad will be displayed as soon as it is ready.
- Changes only for `InterstitialAd`, `RewardedAd`, `RewardedInterstitialAd`, `AppOpenAd`.
```swift
AdMobManager.shared.showFullFeature(from: Date)
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
Ads are displayed automatically.
Includes types:
`FullScreen`
`Bonus`
`Medium`
`Size1`...`Size13`

#### **a) CollectionViewCell**
This class returns a UICollectionViewCell displaying NativeAd.

##### Register
```swift
collectionView.register(ofType: Size1NativeAdCollectionViewCell.self)
```

##### Datasource
```swift
func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
  let cell = collectionView.dequeue(ofType: Size1NativeAdCollectionViewCell.self, indexPath: indexPath)
  cell.adView.register(id: String)
//            Optional
  return cell
}
```

#### **b) TableViewCell**
This class returns a UITableViewCell displaying NativeAd.

##### Register
```swift
tableView.register(ofType: Size1NativeAdTableViewCell.self)
```

##### Datasource
```swift
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
  let cell = tableView.dequeue(ofType: Size1NativeAdTableViewCell.self, indexPath: indexPath)
//            Optional
  return cell
}
```

#### **c) View**
There are two ways you can create a UIView displaying NativeAd:
- By storyboard, changing class of any `UIView` to `Size1NativeAdView`. _**Note**: Set `Module` to `AdMobManager`._
- By code, using initializer.

#### **d) Determine the height**
```swift
Size1NativeAdView.adHeight()
```
```swift
Size5NativeAdCollectionViewCell.adHeightMinimum(width: collectionView.frame.width)
```

#### **e) Optional**
```swift
.changeColor()
```
```swift
.changeFont()
```
```swift
.changeLoading()
```

### 4. BannerAd
Ads are displayed automatically.
Then, there are two ways you can create `BannerAdView`:
- By storyboard, changing class of any `UIView` to `BannerAdView`. _**Note**: Set `Module` to `AdMobManager`._
- By code, using initializer.

## License
### [ProX Global](https://proxglobal.com)
### Copyright (c) Trịnh Xuân Minh 2022 [@trinhxuanminh](minhtx@proxglobal.com)
