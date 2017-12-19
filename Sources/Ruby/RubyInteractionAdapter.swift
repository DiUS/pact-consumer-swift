import Foundation

class RubyInteractionAdapter {
  var interaction: Interaction

  public init(_ interaction: Interaction) {
    self.interaction = interaction
  }

  func adapt() -> [String: Any] {
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

  private func adaptRequest(_ request: Request) -> [String: Any] {
    var transformedRequest: [String: Any] = [:]
    transformedRequest = ["method": httpMethod(request.method), "path": request.path]
    if let headersValue = request.headers {
      transformedRequest["headers"] = headersValue
    }
    if let bodyValue = request.body {
      transformedRequest["body"] = bodyValue
    }
    if let queryValue = request.query {
      transformedRequest["query"] = queryValue
    }
    return transformedRequest
  }

  private func adaptResponse(_ response: Response) -> [String: Any] {
    var transformedResponse: [String: Any] = [:]
    transformedResponse = ["status": response.status]
    if let headersValue = response.headers {
      transformedResponse["headers"] = headersValue
    }
    if let bodyValue = response.body {
      transformedResponse["body"] = bodyValue
    }
    return transformedResponse
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
