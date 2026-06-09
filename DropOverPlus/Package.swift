// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DropOverPlus",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "DropOverPlus",
            path: "Sources"
        )
    ]
)
