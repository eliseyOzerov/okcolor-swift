// swift-tools-version: 6.1

import PackageDescription

let package = Package(
	name: "OKColor",
	platforms: [.iOS(.v18), .macOS(.v14), .tvOS(.v17), .visionOS(.v1)],
	products: [
		.library(name: "OKColor", targets: ["OKColor"]),
	],
	targets: [
		.target(name: "OKColor"),
		.testTarget(name: "OKColorTests", dependencies: ["OKColor"]),
	]
)
