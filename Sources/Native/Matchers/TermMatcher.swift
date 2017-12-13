import Foundation

@objc
public class TermMatcher: NSObject, MatchingRule {
  let typeValue: Any
  let regex: String

  public init(regex: String, value: Any) {
    self.typeValue = value
    self.regex = regex
  }

  public func rule() -> [String : String] {
    return [ "match": "regex", "regex": regex ]
  }

  public func value() -> Any {
    return typeValue
  }
}
