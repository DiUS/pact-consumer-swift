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

@objc
open class Matcher: NSObject {
  @objc
  public class func term(matcher: String, generate: Any) -> Any {
    return RubyMatcher().term(matcher: matcher, generate: generate)
  }

  @objc
  public class func somethingLike(_ value: Any) -> Any {
    return RubyMatcher().somethingLike(value)
  }

  @objc
  public class func eachLike(_ value: Any, min: Int = 1) -> Any {
    return RubyMatcher().eachLike(value, min: min)
  }
}
