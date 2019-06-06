public protocol MatchingRule {
  func value() -> Any
  func rule() -> [String: Any]
}
