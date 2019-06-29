import Foundation

@objc
open class Matcher: NSObject {

  @objc
  public class func term(matcher: String, generate: String) -> [String: Any] {
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
  public class func somethingLike(_ value: Any) -> [String: Any] {
    return [
      "json_class": "Pact::SomethingLike",
      "contents": value
    ]
  }

  @objc
  public class func eachLike(_ value: Any, min: Int = 1) -> [String: Any] {
    return [
      "json_class": "Pact::ArrayLike",
      "contents": value,
      "min": min
    ]
  }
}
