import Foundation

@objc
open class RubyMatcher: NSObject, Matchers {
  @objc
  public func term(matcher: String, generate: Any) -> MatchingRule {
    return RubyTermMatcher(regex: matcher, value: generate)
  }

  @objc
  public func somethingLike(_ value: Any) -> MatchingRule {
    return RubyTypeMatcher(value: value)
  }

  @objc
  public func eachLike(_ value: [String: Any], min: Int) -> MatchingRule {
    return RubyMinTypeMatcher(value: value, min: min)
  }
}

public class RubyTermMatcher: TermMatcher, MatchingRule {
  public func rule() -> [String: Any] {
    return [ "json_class": "Pact::Term",
    "data": [
      "generate": typeValue,
      "matcher": [
        "json_class": "Regexp",
        "o": 0,
        "s": regex]
    ] ]
  }
}

public class RubyTypeMatcher: TypeMatcher, MatchingRule {
  public func rule() -> [String: Any] {
    return [
      "json_class": "Pact::SomethingLike",
      "contents": typeValue
    ]
  }
}

public class RubyMinTypeMatcher: MinTypeMatcher, MatchingRule {
    public func rule() -> [String: Any] {
        return [
          "json_class": "Pact::ArrayLike",
          "contents": typeValue,
          "min": min
        ]
    }
}
