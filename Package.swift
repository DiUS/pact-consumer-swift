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
    .package(url: "https://github.com/antitypical/Result.git", from: "5.0.0"),
    .package(url: "https://github.com/Quick/Quick.git", from: "2.1.0"),
    .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.0"),
    .package(url: "https://github.com/Thomvis/BrightFutures.git", from: "8.0.0")
  ],
  targets: [
    .target(
      name: "PactConsumerSwift",
      dependencies: ["BrightFutures", "Nimble", "Result"],
      path: "./Sources"
    ),
    .testTarget(
      name: "PactConsumerSwiftTests",
      dependencies: ["PactConsumerSwift", "BrightFutures", "Nimble", "Quick", "SwiftyJSON"],
      path: "./Tests/Swift"
    )
  ]
)
