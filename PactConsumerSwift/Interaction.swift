import Alamofire

@objc public enum PactHTTPMethod: Int {
  case OPTIONS, GET, HEAD, POST, PUT, PATCH, DELETE, TRACE, CONNECT
}

@objc open class Interaction: NSObject {
  open var providerState: String?
  open var testDescription: String = ""
  open var request: [String: Any] = [:]
  open var response: [String: Any] = [:]

  @discardableResult
  open func given(_ providerState: String) -> Interaction {
    self.providerState = providerState
    return self
  }

  @discardableResult
  open func uponReceiving(_ testDescription: String) -> Interaction {
    self.testDescription = testDescription
    return self
  }

  @objc(withRequestHTTPMethod: path: query: headers: body:)
  @discardableResult
  open func withRequest(method: PactHTTPMethod,
                        path: Any,
                        query: Any? = nil,
                        headers: [String: Any]? = nil,
                        body: Any? = nil) -> Interaction {
    request = ["method": httpMethod(method), "path": path]
    if let headersValue = headers {
      request["headers"] = headersValue
    }
    if let bodyValue = body {
      request["body"] = bodyValue
    }
    if let queryValue = query {
      request["query"] = queryValue
    }
    return self
  }

  @objc(willRespondWithHTTPStatus: headers: body:)
  @discardableResult
  open func willRespondWith(status: Int,
                            headers: [String: Any]? = nil,
                            body: Any? = nil) -> Interaction {
    response = ["status": status]
    if let headersValue = headers {
      response["headers"] = headersValue
    }
    if let bodyValue = body {
      response["body"] = bodyValue
    }
    return self
  }

  open func payload() -> [String: Any] {
    var payload: [String: Any] = ["description": testDescription,
                                  "request": request,
                                  "response": response ]
    if let providerState = providerState {
      payload["providerState"] = providerState
    }
    return payload
  }

  fileprivate func httpMethod(_ method: PactHTTPMethod) -> String {
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
