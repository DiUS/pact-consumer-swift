import Foundation

@objc
protocol Matchers {

  @objc
  func term(matcher: String, generate: Any) -> Any

  @objc
  func somethingLike(_ value: Any) -> Any

  @objc
  func eachLike(_ value: Any, min: Int) -> Any
}
