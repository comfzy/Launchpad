// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Launchpad",
    platforms: [
        .macOS(.v14)
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "Launchpad",
            dependencies: []),
    ]
)