// swift-tools-version:5.0

import PackageDescription

let package = Package(
  name: "PactConsumerSwift",
  platforms: [
    .macOS(.v10_10), .iOS(.v8), .tvOS(.v9)
  ],
  products: [
    .library(name: "PactConsumerSwift", targets: ["PactConsumerSwift"])
  ],
  dependencies: [
    .package(url: "https://github.com/Quick/Nimble.git", from: "8.0.0"),
    .package(url: "https://github.com/Quick/Quick.git", from: "2.2.0")
  ],
  targets: [
    .target(
      name: "PactConsumerSwift",
      path: "./Sources"
    ),
    .testTarget(
      name: "PactConsumerSwiftTests",
      dependencies: [
        "PactConsumerSwift",
        "Nimble",
        "Quick"
      ],
      path: "./Tests"
    )
  ]
)
