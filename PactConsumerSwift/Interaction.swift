import Alamofire

@objc public enum PactHTTPMethod: Int {
  case OPTIONS, GET, HEAD, POST, PUT, PATCH, DELETE, TRACE, CONNECT
}

@objc public class Interaction: NSObject {
  public var providerState: String? = nil
  public var testDescription: String = ""
  public var request: Dictionary<String, AnyObject> = [:]
  public var response: Dictionary<String, AnyObject> = [:]


  public func given(providerState: String) -> Interaction {
    self.providerState = providerState
    return self
  }

  public func uponReceiving(testDescription: String) -> Interaction {
    self.testDescription = testDescription
    return self
  }

  @objc(withRequestHTTPMethod: path: query: headers: body:)
  public func withRequest(method method: PactHTTPMethod, path: String, query: Dictionary<String, AnyObject>? = nil, headers: Dictionary<String, String>? = nil, body: AnyObject? = nil) -> Interaction {
    request = ["method": httpMethod(method), "path": path]
    if let headersValue = headers {
      request["headers"] = headersValue
    }
    if let bodyValue: AnyObject = body {
      request["body"] = bodyValue
    }
    if let queryValue: AnyObject = query {
      request["query"] = queryValue
    }
    return self
  }

  @objc(willRespondWithHTTPStatus: headers: body:)
  public func willRespondWith(status status: Int, headers: Dictionary<String, String>? = nil, body: AnyObject? = nil) -> Interaction {
    response = ["status": status]
    if let headersValue = headers {
      response["headers"] = headersValue
    }
    if let bodyValue: AnyObject = body {
      response["body"] = bodyValue
    }
    return self
  }

  public func payload() -> [String: AnyObject] {
    var payload: [String: AnyObject] = ["description": testDescription, "request": request, "response": response ]
    if let providerState = providerState {
      payload["providerState"] = providerState
    }
    return payload
  }

  private func httpMethod(method: PactHTTPMethod) -> String {
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
