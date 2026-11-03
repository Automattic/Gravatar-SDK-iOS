// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Gravatar-Demo",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16),
        .macOS(.v14),
    ],
    products: [
        .library(name: "Gravatar-Demo", targets: ["Gravatar-Demo"]),
    ],
    dependencies: [
        .package(name: "Gravatar", path: ".."),
    ],
    targets: [
        .target(
            name: "Gravatar-Demo",
            dependencies: [
                .product(name: "Gravatar", package: "Gravatar"),
                .product(name: "GravatarUI", package: "Gravatar"),
            ],
            path: "Demo",
            exclude: [
                "Base.xcconfig",
                "Enterprise.xcconfig",
                "Generated",
                "Localizations",
                "Gravatar-Demo/Info.plist",
                "Gravatar-Demo/Gravatar-Demo.Base.xcconfig",
                "Gravatar-Demo/Gravatar-Demo.Release.xcconfig",
            ],
            resources: [
                .process("Gravatar-Demo/Assets.xcassets"),
                .process("Gravatar-Demo/Base.lproj"),
            ],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
    ]
)
