typealias JSONEntry = [String: Any]
typealias JSONArray = [Any]
typealias PathWithMatchingRule = [String: [String: Any]]

class PactBodyBuilder {
  let bodyDefinition: Any

  public init(body: Any) {
    self.bodyDefinition = body
  }

  func build() -> PactBody {
    return buildBody(definition: self.bodyDefinition)
  }

  func buildBody(definition: Any) -> PactBody {
    let processedBody = processElement(path: "$.body", element: definition)
    return PactBody(body: processedBody.0, matchingRules: processedBody.1)
  }

  func processElement(path: String, element: Any) -> (Any, PathWithMatchingRule) {
    let result: (Any, PathWithMatchingRule)
    switch element {
    case let array as JSONArray:
      result = processArray(array, path: path)
    case let dictionary as JSONEntry:
      result = processDictionary(dictionary, path: path)
    case let matcher as MinTypeMatcher:
      result = processElement(path: "\(path)[*]", element: matcher.value())
    case let matcher as MatchingRule:
      result = (matcher.value(), [path: matcher.rule()])
    default:
      print(path, element)
      result = (element, [:])
    }
    return result
  }

  private func eachLikeMatchingRule(path: String, element: Any) -> PathWithMatchingRule? {
    guard let eachLikeElement = element as? MinTypeMatcher else {
      return nil
    }
    return [path: eachLikeElement.rule()]
  }

  func processArray(_ array: JSONArray, path: String) -> (Any, PathWithMatchingRule) {
    var matches: PathWithMatchingRule = [:]
    var processedArray: JSONArray = []
    for (index, arrayValue) in array.enumerated() {
      if let eachLikeRule = eachLikeMatchingRule(path: path, element: arrayValue) {
        matches = matches.merge(dictionary: eachLikeRule)
      }
      let processedSubElement = processElement(path: "\(path)[\(index)]", element: arrayValue)
      processedArray.append(processedSubElement.0)
      matches = matches.merge(dictionary: processedSubElement.1)
    }
    return (processedArray, matches)
  }

  func processDictionary(_ dictionary: JSONEntry, path: String) -> (Any, PathWithMatchingRule) {
    var matches: PathWithMatchingRule =  [:]
    var processedDictionary: JSONEntry = [:]
    for jsonKey in dictionary.keys {
      if let dictionaryValue = dictionary[jsonKey] {
        if let eachLikeRule = eachLikeMatchingRule(path: path, element: dictionaryValue) {
          matches = matches.merge(dictionary: eachLikeRule)
        }
        let processedSubElement = processElement(path: "\(path).\(jsonKey)", element: dictionaryValue)
        processedDictionary[jsonKey] = processedSubElement.0
        matches = matches.merge(dictionary: processedSubElement.1)
      }
    }
    return (processedDictionary, matches)
  }
}

struct PactBody {
  var body: Any
  var matchingRules: PathWithMatchingRule
}
