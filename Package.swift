// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BilibiliKit",
    platforms: [
        // .iOS(.v8), .macOS(.v10_10), .tvOS(.v9), .watchOS(.v2)
        .iOS(.v10), .macOS(.v10_12), .tvOS(.v10), .watchOS(.v3),
    ],
    products: [
        .library(
            name: "BilibiliKit",
            targets: ["BilibiliKit"]),
    ],
    dependencies: [
        // .package(url: "https://github.com/apple/swift-crypto", from: "1.0.1"),
    ],
    targets: [
        .target(
            name: "BilibiliKit",
            dependencies: ["BKSecurity"]),
        .target(
            name: "BKSecurity",
            dependencies: [
                // Will need to wait for 5.3
                // .product(name: "Crypto", condition: .when(platforms: [.linux])),
                "BKFoundation"
        ]),
        .target(
            name: "BKFoundation"),
        .testTarget(
            name: "BilibiliKitTests",
            dependencies: ["BilibiliKit"]),
    ]
)
