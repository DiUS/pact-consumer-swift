import Alamofire

public class Interaction {
    private var providerState: String?
    private var description: String?
    private var request: Dictionary<String, Any>?
    private var response: Dictionary<String, AnyObject>?

    public init() {}

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
        request = [ "method": method, "path": path ]
        return self
    }

    public func willRespondWith(status: Int, headers: Dictionary<String, String>, body: String) -> Interaction {
        request = [ "status": status, "headers": headers, "body": body ]
        return self
    }
}