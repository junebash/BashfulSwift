// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "BashfulSwift",
	platforms: [SupportedPlatform.iOS(.v13), SupportedPlatform.macOS(.v10_15)],
	products: [
		.library(name: "BashfulCore", targets: ["BashfulCore"]),
		.library(name: "BashfulUIKit", targets: ["BashfulUIKit"]),
		.library(name: "BashfulFun", targets: ["BashfulFun"]),
	],
	targets: [
		.target(
			name: "BashfulCore",
			dependencies: []),
		.testTarget(
			name: "CoreTests",
			dependencies: ["BashfulCore"],
			path: "./Tests/CoreTests"),

		.target(
			name: "BashfulFun",
			dependencies: ["BashfulCore"]),
		.testTarget(
			name: "FunTests",
			dependencies: ["BashfulFun"],
			path: "./Tests/FunTests"),

		.target(
			name: "BashfulUIKit",
			dependencies: ["BashfulCore"]),
		.testTarget(
			name: "UIKitTests",
			dependencies: ["BashfulUIKit"],
			path: "./Tests/UIKitTests")
	]
)
