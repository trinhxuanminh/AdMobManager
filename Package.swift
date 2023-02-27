// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "AdMobManager",
  platforms: [.iOS(.v10)],
  products: [
    // Products define the executables and libraries a package produces, and make them visible to other packages.
    .library(
      name: "AdMobManager",
      targets: ["AdMobManager"]),
  ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    // .package(url: /* package url */, from: "1.0.0"),
    .package(name: "GoogleMobileAds", url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git", from: "9.6.0"),
    .package(name: "NVActivityIndicatorView", url: "https://github.com/ninjaprox/NVActivityIndicatorView", from: "5.1.1"),
    .package(name: "SnapKit", url: "https://github.com/SnapKit/SnapKit", from: "5.6.0"),
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages this package depends on.
    .target(
      name: "AdMobManager",
      dependencies: [
        "GoogleMobileAds",
        "NVActivityIndicatorView",
        "SnapKit",
      ],
      resources: [
        .process("AdView/Size1/Size1NativeAdView.xib"),
        .process("AdView/Size2/Size2NativeAdView.xib"),
        .process("AdView/Size3/Size3NativeAdView.xib"),
        .process("AdView/Size4/Size4NativeAdView.xib"),
        .process("AdView/Size5/Size5NativeAdView.xib"),
        .process("AdView/Size6/Size6NativeAdView.xib"),
        .process("AdView/Size7/Size7NativeAdView.xib"),
        .process("AdView/Size8/Size8NativeAdView.xib"),
        .process("AdView/Size9/Size9NativeAdView.xib"),
        .process("AdView/Bonus/BonusNativeAdView.xib"),
        .process("AdView/FullScreen/FullScreenNativeAdView.xib"),
        .process("AdView/Medium/MediumNativeAdView.xib"),
      ]
    )
  ]
)
