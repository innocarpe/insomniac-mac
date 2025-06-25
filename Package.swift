// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Insomniac",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(
            name: "Insomniac",
            targets: ["Insomniac"]
        )
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "Insomniac",
            dependencies: []
        ),
        .testTarget(
            name: "InsomniacTests",
            dependencies: ["Insomniac"]
        )
    ]
)