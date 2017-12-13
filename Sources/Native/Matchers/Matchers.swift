import Foundation

@objc
open class Matchers: NSObject {

  @objc
  open class func term(_ matcher: String, generate: Any) -> TermMatcher {
    return TermMatcher(regex: matcher, value: generate)
  }

  @objc
  open class func somethingLike(_ value: Any) -> TypeMatcher {
    return TypeMatcher(value: value)
  }

  @objc
  open class func eachLike(_ value: Any, min: Int = 1) -> [String: Any] {
    return [
      "json_class": "Pact::ArrayLike",
      "contents": value,
      "min": min
    ]
  }
}
