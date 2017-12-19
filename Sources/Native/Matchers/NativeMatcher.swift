import Foundation

@objc
open class NativeMatcher: NSObject, Matchers {

  @objc
  public func term(matcher: String, generate: Any) -> Any {
    let sanitizedString = matcher.replacingOccurrences(of: "\\/", with: "/")
    return TermMatcher(regex: sanitizedString, value: generate)
  }

  @objc
  public func somethingLike(_ value: Any) -> Any {
    return TypeMatcher(value: value)
  }

  @objc
  public func eachLike(_ value: Any, min: Int = 1) -> Any {
    return [
      "json_class": "Pact::ArrayLike",
      "contents": value,
      "min": min
    ]
  }
}
