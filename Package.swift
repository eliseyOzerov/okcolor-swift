// swift-tools-version: 6.1

import PackageDescription

let package = Package(
	name: "OkColor",
	platforms: [.iOS(.v18), .macOS(.v14), .tvOS(.v17), .visionOS(.v1)],
	products: [
		.library(name: "OkColor", targets: ["OkColor"]),
	],
	targets: [
		.target(name: "OkColor"),
		.testTarget(
			name: "OkColorTests",
			dependencies: ["OkColor"],
			resources: [.process("Fixtures")]
		),
	]
)
