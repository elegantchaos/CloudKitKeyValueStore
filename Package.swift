// swift-tools-version:5.2

// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 15/04/2021.
//  All code (c) 2021 - present day, Elegant Chaos.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import PackageDescription

let package = Package(
    name: "CloudKitKeyValueStore",
    platforms: [
        .macOS(.v10_13), .iOS(.v13), .tvOS(.v13), .watchOS(.v6)
    ],
    products: [
        .library(
            name: "CloudKitKeyValueStore",
            targets: ["CloudKitKeyValueStore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/elegantchaos/XCTestExtensions.git", from: "1.2.0")
    ],
    targets: [
        .target(
            name: "CloudKitKeyValueStore",
            dependencies: []),
        .testTarget(
            name: "CloudKitKeyValueStoreTests",
            dependencies: ["CloudKitKeyValueStore", "XCTestExtensions"]),
    ]
)
