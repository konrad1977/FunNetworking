// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FunNetworking",
	platforms: [
		.iOS(.v9),
		.macOS(.v10_11)
	],
    products: [
        .library(name: "FunNetworking", targets: ["FunNetworking"])
    ],
    dependencies: [
		.package(name: "Funswift", url: "https://github.com/konrad1977/funswift", .branch("main")),
    ],
    targets: [
        .target(
            name: "FunNetworking",
            dependencies: ["Funswift"]),
        .testTarget(
            name: "FunNetworkingTests",
            dependencies: ["FunNetworking"]),
    ]
)
