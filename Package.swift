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
    .package(name: "GoogleMobileAds", url: "https://github.com/quanghits/GoogleMobileAds.git", from: "9.1.0"),
    .package(name: "SkeletonView", url: "https://github.com/Juanpe/SkeletonView.git", from: "1.29.3"),
    .package(name: "SnapKit", url: "https://github.com/SnapKit/SnapKit", from: "5.6.0"),
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages this package depends on.
    .target(
      name: "AdMobManager",
      dependencies: [
        "GoogleMobileAds",
        "SkeletonView",
        "SnapKit",
      ],
      resources: [
        .process("AdCollectionViewCell/Normal/NativeAdCollectionViewCell.xib"),
        .process("AdCollectionViewCell/Advanced/NativeAdvancedAdCollectionViewCell.xib"),
        .process("AdView/Normal/NativeAdView.xib"),
        .process("AdView/Advanced/NativeAdvancedAdView.xib"),
        .process("AdTableViewCell/Normal/NativeAdTableViewCell.xib"),
        .process("AdTableViewCell/Advanced/NativeAdvancedAdTableViewCell.xib"),
      ]
    )
  ]
)
