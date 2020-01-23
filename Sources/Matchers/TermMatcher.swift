import Foundation

@objc public class TermMatcher: NSObject {
    let typeValue: Any
    let regex: String

    public init(regex: String, value: Any) {
      self.typeValue = value
      self.regex = regex
    }

    @objc public func value() -> Any {
      return typeValue
    }

}
