// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LWFileDownload",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "LWFileDownload",
            targets: ["LWFileDownload"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "LWFileDownload",
            dependencies: [],
            path: "LWFileDownload/Classes",
            exclude: ["LWFileDownloadManager.h", "LWFileDownloadManager.m"],
            sources: [
                "LWFileDownloadManager.swift",
                "LWFileDownloadTask.swift",
                "LWFileDownloadViewModel.swift",
                "LWFileDownloadView.swift"
            ],
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug))
            ]
        )
    ]
)
