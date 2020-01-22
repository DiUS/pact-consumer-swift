import Foundation

@objc
open class RubyMatcher: NSObject, Matchers {
  @objc
  public func term(matcher: String, generate: String) -> MatchingRule {
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

// merge-todo clean up / split up files / maybe generalize
@objc
public class RubyTermMatcher: NSObject, MatchingRule {
  let typeValue: String
  let regex: String

  public init(regex: String, value: String) {
    self.typeValue = value
    self.regex = regex
  }

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

  public func value() -> Any {
    return typeValue
  }
}

@objc
public class RubyTypeMatcher: NSObject, MatchingRule {
  let typeValue: Any

  public init(value: Any) {
    self.typeValue = value
  }

  public func rule() -> [String: Any] {
    return [
      "json_class": "Pact::SomethingLike",
      "contents": typeValue
    ]
  }

  public func value() -> Any {
    return typeValue
  }
}

@objc
public class RubyMinTypeMatcher: NSObject, MatchingRule {
    let typeValue: [String: Any]
    let min: Int

    public init(value: [String: Any], min: Int) {
        self.typeValue = value
        self.min = min
    }

    public func rule() -> [String: Any] {
        return [
          "json_class": "Pact::ArrayLike",
          "contents": typeValue,
          "min": min
        ]
    }

    public func value() -> Any {
        return typeValue
    }
}
