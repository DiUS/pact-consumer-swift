import Foundation

public class Matcher {

  /*
    NB: This is a Pact version 1 matcher. It is ruby specific, so it will only work when verifying agains a server with the
    ruby gem.
  */
  @objc public class func term(matcher matcher: String, generate: String) -> [String: AnyObject] {
    return [ "json_class": "Pact::Term",
             "data": [
                     "generate": generate,
                     "matcher": [
                             "json_class": "Regexp",
                             "o": 0,
                             "s": matcher
                     ]
             ] ]
  }

  /*
    NB: This is a Pact version 1 matcher. It is ruby specific, so it will only work when verifying agains a server with the
    ruby gem.
  */
  @objc public class func somethingLike(value: AnyObject) -> [String: AnyObject] {
    return [
            "json_class": "Pact::SomethingLike",
            "contents" : value
    ]
  }

}
