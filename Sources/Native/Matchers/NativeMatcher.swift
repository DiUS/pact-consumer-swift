import Foundation

@objc
open class NativeMatcher: NSObject, Matchers {

  @objc
  public func term(matcher: String, generate: String) -> MatchingRule {
    let sanitizedString = matcher.replacingOccurrences(of: "\\/", with: "/")
    return TermMatcher(regex: sanitizedString, value: generate)
  }

  @objc
  public func somethingLike(_ value: Any) -> MatchingRule {
    return TypeMatcher(value: value)
  }

  @objc
  public func eachLike(_ value: [String: Any], min: Int) -> MatchingRule {
    return MinTypeMatcher(value: value, min: min)
  }
}
