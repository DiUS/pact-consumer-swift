import Foundation

@objc
public class PactInteractionAdapter: NSObject {
  typealias HttpMessage = [String: Any]
  typealias QueryParameter = [String: Any]
  var interaction: Interaction

  public init(_ interaction: Interaction) {
    self.interaction = interaction
  }

  private func adaptRequest(_ request: Request) -> HttpMessage {
    var transformedRequest: HttpMessage = [:]
    transformedRequest = ["method": httpMethod(request.method)]
    transformedRequest = applyPath(message: transformedRequest, path: request.path)
    transformedRequest = applyHeaders(message: transformedRequest, headers: request.headers)
    transformedRequest = applyQuery(message: transformedRequest, query: request.query)
    transformedRequest = applyBody(message: transformedRequest, body: request.body)
    return transformedRequest
  }

  private func adaptResponse(_ response: Response) -> HttpMessage {
    var transformedResponse: HttpMessage = [:]
    transformedResponse = ["status": response.status]
    transformedResponse = applyHeaders(message: transformedResponse, headers: response.headers)
    transformedResponse = applyBody(message: transformedResponse, body: response.body)
    return transformedResponse
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
      return message.merge(dictionary: ["path": path])
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

  public func adapt() -> [String: Any] {
    var payload: [String: Any] = ["description": self.interaction.testDescription as Any]

    if let request = self.interaction.request {
      payload["request"] = adaptRequest(request)
    }
    if let response = self.interaction.response {
      payload["response"] = adaptResponse(response)
    }
    if let providerState = self.interaction.providerState {
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
