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
            targets: ["Gravatar"]),
        .library(
            name: "GravatarCore",
            targets: ["GravatarCore"]
        ),
        .library(
            name: "GravatarUIComponents",
            targets: ["GravatarUIComponents"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/nicklockwood/SwiftFormat", from: "0.53.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Gravatar",
            dependencies: [
                "GravatarCore",
                .byName(name: "GravatarUIComponents", condition: .when(platforms: [.iOS]))
            ]
        ),
        .testTarget(
            name: "GravatarTests",
            dependencies: ["Gravatar"],
            resources: [.process("Resources")]
        ),
        .target(name: "GravatarCore"),
        .testTarget(
            name: "GravatarCoreTests",
            dependencies: ["GravatarCore"],
            resources: [.process("Resources")]
        ),
        .target(
            name: "GravatarUIComponents",
            dependencies: ["GravatarCore"]
        ),
        .testTarget(
            name: "GravatarUIComponentsTests",
            dependencies: ["GravatarUIComponents"],
            resources: [.process("Resources")]
        ),
    ]
)
