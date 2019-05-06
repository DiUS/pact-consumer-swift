import Foundation

@objc
public protocol Matchers {

  @objc
  func term(matcher: String, generate: Any) -> Any

  @objc
  func somethingLike(_ value: Any) -> Any

  @objc
  func eachLike(_ value: Any, min: Int) -> Any
}

@objc
public class Matcher: NSObject {
  @objc
  static var matchers: Matchers = RubyMatcher()

  @objc
  public class func term(matcher: String, generate: Any) -> Any {
    return matchers.term(matcher: matcher, generate: generate)
  }

  @objc
  public class func somethingLike(_ value: Any) -> Any {
    return matchers.somethingLike(value)
  }

  @objc
  public class func eachLike(_ value: Any, min: Int = 1) -> Any {
    return matchers.eachLike(value, min: min)
  }
}
