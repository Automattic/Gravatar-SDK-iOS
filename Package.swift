// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Gravatar",
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
        .package(url: "https://github.com/nicklockwood/SwiftFormat", from: "0.53.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Gravatar"
        ),
        .testTarget(
            name: "GravatarTests",
            dependencies: ["Gravatar", "TestHelpers"],
            resources: [.process("Resources")]
        ),
        .target(
            name: "GravatarUI",
            dependencies: ["Gravatar"]
        ),
        .testTarget(
            name: "GravatarUITests",
            dependencies: ["GravatarUI", "TestHelpers"],
            resources: [.process("Resources")]
        ),
        .target(
            name: "TestHelpers",
            dependencies: ["Gravatar"],
            resources: [.process("Resources")]
        )
    ]
)
