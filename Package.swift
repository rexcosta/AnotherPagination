// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AnotherPagination",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "AnotherPagination",
            targets: ["AnotherPagination"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/rexcosta/AnotherSwiftCommonLib.git",
            .branch("master")
        )
    ],
    targets: [
        .target(
            name: "AnotherPagination",
            dependencies: ["AnotherSwiftCommonLib"]
        ),
        .testTarget(
            name: "AnotherPaginationTests",
            dependencies: ["AnotherPagination"]
        ),
    ]
)
