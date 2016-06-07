import Foundation

@objc public class Matcher: NSObject {

  @objc public class func term(matcher matcher: String, generate: String) -> [String: AnyObject] {
    return [ "json_class": "Pact::Term",
      "data": [
        "generate": generate,
        "matcher": [
          "json_class": "Regexp",
          "o": 0,
          "s": matcher]
      ] ]
  }

  @objc public class func somethingLike(value: AnyObject) -> [String: AnyObject] {
    return [
      "json_class": "Pact::SomethingLike",
      "contents" : value
    ]
  }

  @objc public class func eachLike(value: AnyObject, min: Int = 1) -> [String: AnyObject] {
    return [
      "json_class": "Pact::ArrayLike",
      "contents" : value,
      "min": min
    ]
  }
}
