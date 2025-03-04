// swift-tools-version: 6.0

import PackageDescription

let package = Package(
	name: "swift-existential-container",
	products: [
		.library(
			name: "ExistentialContainer",
			targets: ["ExistentialContainer"]
		),
	],
	targets: [
		.target(name: "ExistentialContainer"),
		.testTarget(
			name: "ExistentialContainerTests",
			dependencies: [
				.target(name: "ExistentialContainer")
			]
		),
	]
)
