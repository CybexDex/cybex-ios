// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftTheme",
    platforms: [.iOS(.v8)],
    products: [
        .library(
            name: "SwiftTheme",
            targets: ["SwiftTheme"]),
    ],
    targets: [
        .target(
            name: "SwiftTheme",
            path: "Sources"),
    ]
)

