@objc
public class PactInteraction: NSObject {
  typealias HttpMessage = [String: Any]
  typealias QueryParameter = [String: Any]
  var providerState: String?
  var testDescription: String = ""
  var request: HttpMessage = [:]
  var response: HttpMessage = [:]

  @discardableResult
  public func given(_ providerState: String) -> PactInteraction {
    self.providerState = providerState
    return self
  }

  @discardableResult
  public func uponReceiving(_ testDescription: String) -> PactInteraction {
    self.testDescription = testDescription
    return self
  }

  @objc(withRequestHTTPMethod: path: query: headers: body:)
  @discardableResult
  public func withRequest(method: PactHTTPMethod,
                          path: Any,
                          query: Any? = nil,
                          headers: [String: Any]? = nil,
                          body: Any? = nil) -> PactInteraction {
    request = ["method": httpMethod(method)]
    request = applyPath(message: request, path: path)
    request = applyHeaders(message: request, headers: headers)
    request = applyQuery(message: request, query: query)
    request = applyBody(message: request, body: body)
    return self
  }

  @objc(willRespondWithHTTPStatus: headers: body:)
  @discardableResult
  public func willRespondWith(status: Int,
                              headers: [String: Any]? = nil,
                              body: Any? = nil) -> PactInteraction {
    response = ["status": status]
    response = applyHeaders(message: response, headers: headers)
    response = applyBody(message: response, body: body)
    return self
  }

  private func applyHeaders(message: HttpMessage, headers: [String: Any]?) -> HttpMessage {
    if let headers = headers {
      let headerBuilder = PactHeaderBuilder(headers: headers).build()
      return message.merge(dictionary: [
        "headers": headerBuilder.headers,
        "matchingRules": matchingRules(message: message, matchingRules: headerBuilder.matchingRules)
      ])
    }
    return message
  }

  private func applyPath(message: HttpMessage, path: Any) -> HttpMessage {
    switch path {
    case let matcher as MatchingRule:
      return message.merge(dictionary: [
        "path": matcher.value(),
        "matchingRules": ["$.path": matcher.rule()]])
    default:
      return message.merge(dictionary:["path": path])
    }
  }

  private func applyQuery(message: HttpMessage, query: Any?) -> HttpMessage {
    if let query = query {
      let queryBuilder = PactQueryBuilder(query: query).build()
      return message.merge(dictionary: [
        "query": queryBuilder.query,
        "matchingRules": matchingRules(message: message, matchingRules: queryBuilder.matchingRules)
      ])
    }
    return message
  }

  private func applyBody(message: HttpMessage, body: Any?) -> HttpMessage {
    if let bodyValue = body {
      let pactBody = PactBodyBuilder(body: bodyValue).build()
      return message.merge(dictionary: [
          "body": pactBody.body,
          "matchingRules": matchingRules(message: message, matchingRules: pactBody.matchingRules)
        ]
      )
    }
    return message
  }

  private func matchingRules(message: HttpMessage, matchingRules: PathWithMatchingRule) -> HttpMessage {
    switch message["matchingRules"] {
      case let existingMatchingRules as PathWithMatchingRule:
        return existingMatchingRules.merge(dictionary: matchingRules)
      default:
        return matchingRules
    }
  }

  public func payload() -> [String: Any] {
    var payload: [String: Any] = ["description": testDescription, "request": request, "response": response ]
    if let providerState = providerState {
      payload["providerState"] = providerState
    }
    return payload
  }

  private func httpMethod(_ method: PactHTTPMethod) -> String {
    switch method {
      case .GET:
        return "get"
      case .HEAD:
        return "head"
      case .POST:
        return "post"
      case .PUT:
        return "put"
      case .PATCH:
        return "patch"
      case .DELETE:
        return "delete"
      case .TRACE:
        return "trace"
      case .CONNECT:
        return "connect"
      default:
        return "get"
    }
  }
}
