typealias JSONEntry = [String: Any]
typealias JSONArray = [Any]
typealias PathWithMatchingRule = [String: [String: String]]

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
    switch element {
    case let array as JSONArray:
      return processArray(array, path: path)
    case let dictionary as JSONEntry:
      return processDictionary(dictionary, path: path)
    case let matcher as MatchingRule:
      return (matcher.value(), [path: matcher.rule()])
    default:
      print(path, element)
    }
    return (element, [:])
  }

  func processArray(_ array: JSONArray, path: String) -> (Any, PathWithMatchingRule) {
    var matches: PathWithMatchingRule = [:]
    var processedArray: JSONArray = []
    for (index, arrayValue) in array.enumerated() {
      let processedSubElement = processElement(path: "\(path)[\(index)]", element: arrayValue)
      processedArray.append(processedSubElement.0)
      matches = matches.merge(dictionary: processedSubElement.1)
    }
    return (processedArray, matches)
  }

  func processDictionary(_ dictionary: JSONEntry, path: String) -> (Any, PathWithMatchingRule) {
    var matches: PathWithMatchingRule =  [:]
    var processedDictionary: JSONEntry = [:]
    for key in dictionary.keys {
      if let dictionaryValue = dictionary[key] {
        let processedSubElement = processElement(path: "\(path).\(key)", element: dictionaryValue)
        matches = matches.merge(dictionary: processedSubElement.1)
        processedDictionary[key] = processedSubElement.0
      }
    }
    return (processedDictionary, matches)
  }
}

struct PactBody {
  var body: Any
  var matchingRules: PathWithMatchingRule
}
