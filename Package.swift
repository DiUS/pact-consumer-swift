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
    .package(url: "https://github.com/Quick/Nimble.git", from: "8.0.0")
  ],
  targets: [
    .target(
      name: "PactConsumerSwift",
      dependencies: ["Nimble"],
      path: "./Sources"
    )
  ]
)
