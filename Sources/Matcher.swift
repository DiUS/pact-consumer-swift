import Foundation

@objc
public protocol Matchers {

  @objc
  func term(matcher: String, generate: Any) -> MatchingRule

  @objc
  func somethingLike(_ value: Any) -> MatchingRule

  @objc
  func eachLike(_ value: [String: Any], min: Int) -> MatchingRule
}

@objc
public class Matcher: NSObject {
  @objc
  static var matchers: Matchers = RubyMatcher()

  @objc
  public class func term(matcher: String, generate: Any) -> MatchingRule {
    return matchers.term(matcher: matcher, generate: generate)
  }

  @objc
  public class func somethingLike(_ value: Any) -> MatchingRule {
    return matchers.somethingLike(value)
  }

  @objc
  public class func eachLike(_ value: [String: Any], min: Int = 1) -> MatchingRule {
    return matchers.eachLike(value, min: min)
  }
}
