// swift-tools-version:5.0

import PackageDescription

let package = Package(
  name: "PactConsumerSwift",
  platforms: [
    .macOS(.v10_10), .iOS(.v9), .tvOS(.v9)
  ],
  products: [
    .library(name: "PactConsumerSwift", targets: ["PactConsumerSwift"])
  ],
  targets: [
    .target(
      name: "PactConsumerSwift",
      path: "./Sources"
    )
  ]
)
