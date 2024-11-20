// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "XSwiftUI",
    platforms: [.iOS(.v15), .macOS(.v11)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "XSwiftUI",
            targets: ["XSwiftUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/airbnb/lottie-spm.git", from: Version(4,4,3)),
        .package(url: "https://github.com/shawon1fb/EasyXConnect.git", from: Version(1,0,5)),
        .package(url: "https://github.com/shawon1fb/EasyX.git", from: Version(1,0,0))
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "XSwiftUI",
            dependencies: [
                .product(name: "Lottie", package: "lottie-spm"),
                .product(name: "EasyXConnect", package: "EasyXConnect"),
                .product(name: "EasyX", package: "EasyX")
            ]
        ),
        .testTarget(
            name: "XSwiftUITests",
            dependencies: ["XSwiftUI"]
        ),
    ]
)
