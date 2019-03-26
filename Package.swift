// swift-tools-version:4.0

import PackageDescription

let package = Package(
  name: "PactConsumerSwift",
  products: [
    .library(
      name: "PactConsumerSwift",
      targets: ["PactConsumerSwift"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/Alamofire/Alamofire.git", from: "4.5.1"),
    .package(url: "https://github.com/Quick/Quick.git", from: "2.0.0"),
    .package(url: "https://github.com/Quick/Nimble.git", from: "8.0.0"),
    .package(url: "https://github.com/Thomvis/BrightFutures.git", from: "5.2.0")
  ],
  targets: [
    .target(
      name: "PactConsumerSwift",
      dependencies: ["Alamofire", "BrightFutures", "Nimble"],
      path: "./Sources"
    ),
    .testTarget(
      name: "PactConsumerSwiftTests",
      dependencies: ["PactConsumerSwift", "Alamofire", "BrightFutures", "Nimble", "Quick"]
    )
  ]
)
