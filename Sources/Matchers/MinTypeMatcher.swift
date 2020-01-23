import Foundation

@objc
public class MinTypeMatcher: NSObject {
    let typeValue: [String: Any]
    let min: Int

    public init(value: [String: Any], min: Int) {
        self.typeValue = value
        self.min = min
    }

    @objc public func value() -> Any {
        return typeValue
    }
}
