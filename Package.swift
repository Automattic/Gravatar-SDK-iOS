// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Gravatar",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Gravatar",
            targets: ["Gravatar"]
        ),
        .library(
            name: "GravatarUI",
            targets: ["GravatarUI"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/nicklockwood/SwiftFormat", from: "0.54.0"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.8.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Gravatar",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "GravatarTests",
            dependencies: ["Gravatar", "TestHelpers"],
            resources: [.process("Resources")],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .target(
            name: "GravatarUI",
            dependencies: ["Gravatar"],
            resources: [.process("Resources")],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "GravatarUITests",
            dependencies: ["GravatarUI", "TestHelpers",
                           .product(name: "SnapshotTesting", package: "swift-snapshot-testing")],
            resources: [.process("Resources"),
                        .process("__Snapshots__")],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .target(
            name: "TestHelpers",
            dependencies: ["Gravatar"],
            resources: [.process("Resources")],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        )
    ]
)
