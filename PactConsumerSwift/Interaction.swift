import Alamofire

@objc public class Interaction {
  public var providerState: String = ""
  public var description: String = ""
  public var request: Dictionary<String, AnyObject> = [:]
  public var response: Dictionary<String, AnyObject> = [:]

  public init() {
  }

  public func given(providerState: String) -> Interaction {
    self.providerState = providerState
    return self
  }

  public func uponReceiving(description: String) -> Interaction {
    self.description = description
    return self
  }

  @objc public func withRequest(method: PactHTTPMethod, path: String, headers: Dictionary<String, String>? = nil, body: AnyObject? = nil) -> Interaction {
    request = ["method": httpMethod(method), "path": path]
    if let headersValue = headers {
      request["headers"] = headersValue
    }
    if let bodyValue: AnyObject = body {
      request["body"] = bodyValue
    }
    return self
  }

  @objc public func willRespondWith(status: Int, headers: Dictionary<String, String>, body: AnyObject? = nil) -> Interaction {
    response = ["status": status, "headers": headers]
    if let bodyValue: AnyObject = body {
      response["body"] = bodyValue
    }
    return self
  }
    
  public func payload() -> [String: AnyObject] {
    return [ "providerState": providerState, "description": description, "request": request, "response": response ]
  }
  
  private func httpMethod(method: PactHTTPMethod) -> String {
    switch method {
      case .Get:
        return "get"
      case .Head:
        return "head"
      case .Post:
        return "post"
      case .Put:
        return "put"
      case .Patch:
        return "patch"
      case .Delete:
        return "delete"
      case .Trace:
        return "trace"
      case .Connect:
        return "connect"
      default:
        return "get"
    }
  }
}