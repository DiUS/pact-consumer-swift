import Foundation

@objc
open class Matcher: NSObject, Matchers {
  @objc
  public class func term(matcher: String, generate: Any) -> Any {
    return Matcher().term(matcher: matcher, generate: generate)
  }

  @objc
  public class func somethingLike(_ value: Any) -> Any {
    return Matcher().somethingLike(value)
  }

  @objc
  public class func eachLike(_ value: Any, min: Int = 1) -> Any {
    return Matcher().eachLike(value, min: min)
  }

  @objc
  public func term(matcher: String, generate: Any) -> Any {
    return [ "json_class": "Pact::Term",
      "data": [
        "generate": generate,
        "matcher": [
          "json_class": "Regexp",
          "o": 0,
          "s": matcher]
      ] ]
  }

  @objc
  public func somethingLike(_ value: Any) -> Any {
    return [
      "json_class": "Pact::SomethingLike",
      "contents": value
    ]
  }

  @objc
  public func eachLike(_ value: Any, min: Int = 1) -> Any {
    return [
      "json_class": "Pact::ArrayLike",
      "contents": value,
      "min": min
    ]
  }
}
