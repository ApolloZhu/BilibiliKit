// swift-tools-version:5.3
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
        .library(
            name: "BilibiliKitDYLIB",
            type: .dynamic,
            targets: ["BilibiliKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-crypto",
                 .upToNextMinor(from: "1.1.2")),
    ],
    targets: [
        .target(
            name: "BilibiliKit",
            dependencies: ["BKFoundation", "BKSecurity", "BKAudio"]),
        .target(
            name: "BKAudio",
            dependencies: ["BKFoundation"]),
        .target(
            name: "BKSecurity",
            dependencies: [
                .product(name: "Crypto", package: "swift-crypto",
                         condition: .when(platforms: [.linux])),
                "BKFoundation"
        ]),
        .target(
            name: "BKFoundation"),
        .testTarget(
            name: "BilibiliKitTests",
            dependencies: ["BilibiliKit"]),
    ]
)
