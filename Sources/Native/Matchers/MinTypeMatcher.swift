import Foundation

@objc
public class MinTypeMatcher: NSObject, MatchingRule {
    let typeValue: [String: Any]
    let min: Int

    public init(value: [String: Any], min: Int) {
        self.typeValue = value
        self.min = min
    }

    public func rule() -> [String: Any] {
        return [
            "match": "type",
            "min": min
        ]
    }

    public func value() -> Any {
        return typeValue
    }
}
