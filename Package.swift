// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Caffeine",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(
            name: "Caffeine",
            targets: ["Caffeine"]
        )
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "Caffeine",
            dependencies: []
        ),
        .testTarget(
            name: "CaffeineTests",
            dependencies: ["Caffeine"]
        )
    ]
)