// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DropOverMini",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "DropOverMini",
            path: "Sources"
        )
    ]
)
