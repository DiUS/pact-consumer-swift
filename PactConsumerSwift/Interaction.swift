import Alamofire

public enum Method: String {
  case OPTIONS = "options"
  case GET = "get"
  case HEAD = "head"
  case POST = "post"
  case PUT = "put"
  case PATCH = "patch"
  case DELETE = "delete"
  case TRACE = "trace"
  case CONNECT = "connect"
}

public class Interaction {
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

  public func withRequest(method: Method, path: String, headers: Dictionary<String, String>? = nil, body: AnyObject? = nil) -> Interaction {
    request = ["method": method.rawValue, "path": path]
    if let headersValue = headers {
      request["headers"] = headersValue
    }
    if let bodyValue = body {
      request["body"] = bodyValue
    }
    return self
  }

  public func willRespondWith(status: Int, headers: Dictionary<String, String>, body: AnyObject? = nil) -> Interaction {
    response = ["status": status, "headers": headers]
    if let bodyValue = body {
      response["body"] = bodyValue
    }
    return self
  }
    
  public func payload() -> [String: AnyObject] {
    return [ "providerState": providerState, "description": description, "request": request, "response": response ]
  }
}