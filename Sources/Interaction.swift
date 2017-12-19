import Foundation

@objc
public enum PactHTTPMethod: Int {
  case OPTIONS, GET, HEAD, POST, PUT, PATCH, DELETE, TRACE, CONNECT
}

struct Request {
  var method: PactHTTPMethod
  var path: Any
  var query: Any?
  var headers: [String: Any]?
  var body: Any?
}

struct Response {
  var status: Int
  var headers: [String: Any]?
  var body: Any?
}

@objc
public class Interaction: NSObject {
  var providerState: String?
  var testDescription: String?
  var request: Request?
  var response: Response?

  @discardableResult
  @objc
  public func given(_ providerState: String) -> Interaction {
    self.providerState = providerState
    return self
  }

  @objc
  @discardableResult
  public func uponReceiving(_ testDescription: String) -> Interaction {
    self.testDescription = testDescription
    return self
  }

  @objc(withRequestHTTPMethod: path: query: headers: body:)
  @discardableResult
  public func withRequest(method: PactHTTPMethod,
                          path: Any,
                          query: Any? = nil,
                          headers: [String: Any]? = nil,
                          body: Any? = nil) -> Interaction {
    request = Request(method: method, path: path, query: query, headers: headers, body: body)
    return self
  }

  @objc(willRespondWithHTTPStatus: headers: body:)
  @discardableResult
  public func willRespondWith(status: Int,
                              headers: [String: Any]? = nil,
                              body: Any? = nil) -> Interaction {
    response = Response(status: status, headers: headers, body: body)
    return self
  }
}
