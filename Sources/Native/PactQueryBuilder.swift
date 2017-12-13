class PactQueryBuilder {
  let queryDefinition: Any

  public init(query: Any) {
    self.queryDefinition = query
  }

  func build() -> PactQuery {
    return buildBody(definition: self.queryDefinition)
  }

  func buildBody(definition: Any) -> PactQuery {
    let processedQuery = processQuery(path: "$.query", query: definition)
    return PactQuery(query: processedQuery.0, matchingRules: processedQuery.1)
  }

  func processQuery(path: String, query: Any) -> (String, PathWithMatchingRule) {
    switch query {
    case let string as String:
      return (string, [:])
    case let dictionary as JSONEntry:
      return processDictionary(dictionary, path: path)
    case let matcher as MatchingRule:
      return ("\(matcher.value())", [path: matcher.rule()])
    default:
      print(path, path)
    }
    return (path, [:])
  }

  func processDictionary(_ dictionary: JSONEntry, path: String) -> (String, PathWithMatchingRule) {
    var queryParams: [String] = []
    var matchingRule: PathWithMatchingRule = [:]
    for (key, value) in dictionary.reversed() {
      switch value {
      case let string as String:
        queryParams.append("\(key)=\(string)")
      case let matcher as MatchingRule:
        queryParams.append("\(key)=\(matcher.value())")
        matchingRule["\(path).\(key)[0]"] = matcher.rule()
      default:
        queryParams.append("\(key)=\(value)")
      }
    }
    return (queryParams.joined(separator: "&"), matchingRule)
  }
}

struct PactQuery {
  var query: String
  var matchingRules: PathWithMatchingRule
}
