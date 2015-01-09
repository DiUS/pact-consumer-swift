import Alamofire

public class Interaction {
  private var providerState: String = ""
  private var description: String = ""
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

  // TODO: Implement own Method struct
  public func withRequest(method: Alamofire.Method, path: String) -> Interaction {
    //public func withRequest(method: Alamofire.Method, path: String, headers: Dictionary<String, String>?, body: String? = nil) -> Interaction {
    request = ["method": "get", "path": path]
    return self
  }

  public func willRespondWith(status: Int, headers: Dictionary<String, String>, body: Dictionary<String, AnyObject>) -> Interaction {
    response = ["status": status, "headers": headers, "body": body]
    return self
  }
    
    public func asDictionary() -> [String: AnyObject] {
        return [ "providerState": providerState, "description": description, "request": request, "response": response ]
    }
}