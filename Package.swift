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
    .package(url: "https://github.com/Alamofire/Alamofire.git", from: "4.8.2"),
    .package(url: "https://github.com/Quick/Quick.git", from: "2.1.0"),
    .package(url: "https://github.com/Quick/Nimble.git", from: "8.0.1"),
    .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.0"),
    .package(url: "https://github.com/Thomvis/BrightFutures.git", from: "8.0.0")
  ],
  targets: [
    .target(
      name: "PactConsumerSwift",
      dependencies: ["Alamofire", "BrightFutures", "Nimble", "SwiftyJSON"],
      path: "./Sources"
    ),
    .testTarget(
      name: "PactConsumerSwiftTests",
      dependencies: ["PactConsumerSwift", "Alamofire", "BrightFutures", "Nimble", "Quick"],
      path: "./Tests/Swift"
    )
  ]
)
