import Foundation

@objc
public class TypeMatcher: NSObject, MatchingRule {
  let typeValue: Any

  public init(value: Any) {
    self.typeValue = value
  }

  public func rule() -> [String: Any] {
    return [ "match": "type" ]
  }

  public func value() -> Any {
    return typeValue
  }
}
