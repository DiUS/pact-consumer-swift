import Foundation

@objc
open class NativeMatcher: NSObject, Matchers {

  @objc
  public func term(matcher: String, generate: Any) -> MatchingRule {
    let sanitizedString = matcher.replacingOccurrences(of: "\\/", with: "/")
    return NativeTermMatcher(regex: sanitizedString, value: generate)
  }

  @objc
  public func somethingLike(_ value: Any) -> MatchingRule {
    return NativeTypeMatcher(value: value)
  }

  @objc
  public func eachLike(_ value: [String: Any], min: Int) -> MatchingRule {
    return NativeMinTypeMatcher(value: value, min: min)
  }
}

@objc
public class NativeTermMatcher: TermMatcher, MatchingRule {
  public func rule() -> [String: Any] {
    return [ "match": "regex", "regex": regex ]
  }
}

@objc
public class NativeTypeMatcher: TypeMatcher, MatchingRule {
  public func rule() -> [String: Any] {
    return [ "match": "type" ]
  }
}

@objc
public class NativeMinTypeMatcher: MinTypeMatcher, MatchingRule {
    public func rule() -> [String: Any] {
        return [
            "match": "type",
            "min": min
        ]
    }
}
