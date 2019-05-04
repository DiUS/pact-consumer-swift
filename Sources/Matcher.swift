import Foundation

@objc
protocol Matchers {

  @objc
  func term(matcher: String, generate: Any) -> Any

  @objc
  func somethingLike(_ value: Any) -> Any

  @objc
  func eachLike(_ value: Any, min: Int) -> Any
}

@objc
open class Matcher: NSObject {
  @objc
  public class func term(matcher: String, generate: Any) -> Any {
    // FIXME: this should be dependent on the mockser type
    return NativeMatcher().term(matcher: matcher, generate: generate)
  }

  @objc
  public class func somethingLike(_ value: Any) -> Any {
    // FIXME: this should be dependent on the mockser type
    return NativeMatcher().somethingLike(value)
  }

  @objc
  public class func eachLike(_ value: Any, min: Int = 1) -> Any {
    // FIXME: this should be dependent on the mockser type
    return NativeMatcher().eachLike(value, min: min)
  }
}
