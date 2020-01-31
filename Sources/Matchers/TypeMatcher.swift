import Foundation

@objc
public class TypeMatcher: NSObject {
  let typeValue: Any

  public init(value: Any) {
    self.typeValue = value
  }

  @objc public func value() -> Any {
    return typeValue
  }
}
