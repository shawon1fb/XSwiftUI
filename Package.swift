// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "XSwiftUI",
    platforms: [.iOS(.v15), .macOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "XSwiftUI",
            targets: ["XSwiftUI"]),
        .library(
            name: "InfiniteScrollView",
            targets: ["InfiniteScrollView"]),
    ],
    dependencies: [
        .package(url: "https://github.com/airbnb/lottie-spm.git", from: Version(4,4,3)),
        .package(url: "https://github.com/shawon1fb/EasyXConnect.git", from: Version(2,2,2)),
        .package(url: "https://github.com/shawon1fb/EasyX.git", from: Version(1,0,0)),
        .package(url: "https://github.com/SDWebImage/SDWebImageSwiftUI.git", from: Version(3,0,0)),
        .package(url: "https://github.com/exyte/SVGView.git", from: Version(1,0,6)),
        .package(url: "https://github.com/shawon1fb/SUIRouter.git", from: Version(1,0,0))
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "XSwiftUI",
            dependencies: [
                .product(name: "Lottie", package: "lottie-spm"),
                .product(name: "EasyXConnect", package: "EasyXConnect"),
                .product(name: "EasyX", package: "EasyX"),
                .product(name: "SDWebImageSwiftUI", package: "SDWebImageSwiftUI"),
                .product(name: "SVGView", package: "SVGView"),
                .product(name: "SUIRouter", package: "SUIRouter"),
            ]
        ),
        .target(
            name: "InfiniteScrollView"
        ),
        .testTarget(
            name: "XSwiftUITests",
            dependencies: ["XSwiftUI"]
        ),
    ]
)
