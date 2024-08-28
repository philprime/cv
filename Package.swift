// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "cv-generator",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.2.0"),
        .package(url: "https://github.com/techprimate/TPPDF", from: "2.6.0"),
    ],
    targets: [
        .executableTarget(name: "cv-generator", dependencies: [
            "TPPDF",
            .product(name: "Algorithms", package: "swift-algorithms")
        ]),
    ]
)
