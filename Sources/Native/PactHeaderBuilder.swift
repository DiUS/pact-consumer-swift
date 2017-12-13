class PactHeaderBuilder {
  let headersDefinition: [String: Any]

  public init(headers: [String: Any]) {
    self.headersDefinition = headers
  }

  func build() -> PactHeaders {
    return buildHeaders(definition: self.headersDefinition)
  }

  func buildHeaders(definition: [String: Any]) -> PactHeaders {
    let processedHeaders = processHeaders(path: "$.headers", headers: definition)
    return PactHeaders(headers: processedHeaders.0, matchingRules: processedHeaders.1)
  }

  func processHeaders(path: String, headers: [String: Any]) -> ([String: Any], PathWithMatchingRule) {
    var processedHeaders: [String: Any] = [:]
    var matchingRule: PathWithMatchingRule = [:]
    for (key, value) in headers.reversed() {
      switch value {
      case let string as String:
        processedHeaders[key] = string
      case let matcher as MatchingRule:
        processedHeaders[key] = matcher.value()
        matchingRule["\(path).\(key)"] = matcher.rule()
      default:
        processedHeaders[key] = value
      }
    }
    return (processedHeaders, matchingRule)
  }
}

struct PactHeaders {
  var headers: [String: Any]
  var matchingRules: PathWithMatchingRule
}
