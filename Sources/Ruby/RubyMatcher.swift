import Foundation

@objc
open class RubyMatcher: NSObject, Matchers {
  @objc
  public func term(matcher: String, generate: Any) -> Any {
    return [ "json_class": "Pact::Term",
      "data": [
        "generate": generate,
        "matcher": [
          "json_class": "Regexp",
          "o": 0,
          "s": matcher]
      ] ]
  }

  @objc
  public func somethingLike(_ value: Any) -> Any {
    return [
      "json_class": "Pact::SomethingLike",
      "contents": value
    ]
  }

  @objc
  public func eachLike(_ value: [String: Any], min: Int) -> Any {
    return [
      "json_class": "Pact::ArrayLike",
      "contents": value,
      "min": min
    ]
  }
}
