// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "YQPhotoBrowser",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "YQPhotoBrowser",
            targets: ["YQPhotoBrowser"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/onevcat/Kingfisher.git", .upToNextMajor(from: "8.8.0")),
        .package(url: "https://github.com/SnapKit/SnapKit.git", .upToNextMajor(from: "5.7.1"))
    ],
    targets: [
        .target(
            name: "YQPhotoBrowser",
            dependencies: [
                .product(name: "Kingfisher", package: "Kingfisher"),
                .product(name: "SnapKit", package: "SnapKit")
            ],
            path: ".",
            exclude: [
                "Pods",
                "YQPhotoBrowser.xcodeproj",
                "YQPhotoBrowser.xcworkspace",
                "YQPhotoBrowserDemo",
                "YQPhotoBrowserUITests",
                "Classes/remove_kingfisher_swiftui.rb"
            ],
            sources: ["Classes"],
            resources: [
                .process("Assets/Assets.xcassets")
            ]
        ),
        .testTarget(
            name: "YQPhotoBrowserTests",
            dependencies: ["YQPhotoBrowser"],
            path: "YQPhotoBrowserTests"
        )
    ]
)
