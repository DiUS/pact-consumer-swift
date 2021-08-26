import Foundation

@objc
public enum PactHTTPMethod: Int {
  case OPTIONS, GET, HEAD, POST, PUT, PATCH, DELETE, TRACE, CONNECT
}

@objc
public class Interaction: NSObject {
  private var providerState: String?
  private var testDescription: String = ""
  private var request: [String: Any] = [:]
  private var response: [String: Any] = [:]

  ///
  /// Define the providers state
  ///
  /// Use this method in the `Arrange` step of your Pact test.
  ///
  ///     myMockService.given("a user exists")
  ///
  /// - Parameter providerState: A description of providers state
  /// - Returns: An `Interaction` object
  ///
  @discardableResult
  public func given(_ providerState: String) -> Interaction {
    self.providerState = providerState
    return self
  }

  ///
  /// Describe the request your provider will receive
  ///
  /// Use this method in the `Arrange` step of your Pact test.
  ///
  ///     myMockService.given("a user exists")
  ///                  .uponReceiving("a request for users")
  ///
  /// - Parameter testDescription: A description of the request to the provider
  /// - Returns: An `Interaction` object
  ///
  @objc
  @discardableResult
  public func uponReceiving(_ testDescription: String) -> Interaction {
    self.testDescription = testDescription
    return self
  }

  ///
  /// Describe the request your consumer will send to your provider
  ///
  /// Use this method in the `Arrange` step of your Pact test.
  ///
  ///     myMockService.given("a user exists")
  ///                  .uponReceiving("a request for users")
  ///                  .withRequest(method:.GET, path: "/users")
  ///
  /// - Parameter method: Enum of available HTTP methods
  /// - Parameter path: an object representing url path component
  /// - Parameter query: an object representing url query components
  /// - Parameter headers: Dictionary representing any headers in network request
  /// - Parameter body: An object representing the body of your network request
  /// - Returns: An `Interaction` object
  ///
  /// - Warning:
  ///  When `query` parameter is provided as a `String` it is **not** percentage encoded to present a valid URL.
  ///  This allows you to prepare a valid URL query such as:
  ///
  ///      ?someKey=value%20with%20space&anotherKey=anotherValue
  ///
  ///  Only when providing a query parameter as a `Dictionary<String, String>` the keys and values are percentage encoded.
  ///
  @objc(withRequestHTTPMethod: path: query: headers: body:)
  @discardableResult
  public func withRequest(method: PactHTTPMethod,
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
      if let queryValue = queryValue as? [String: String] {
        request["query"] = queryValue
          .map { "\($0.key.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? "")=\($0.value.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? "")" } // swiftlint:disable:this line_length
          .joined(separator: "&")

      } else {
        request["query"] = queryValue
      }
    }
    return self
  }

  ///
  /// Describe the response of your provider
  ///
  /// Use this method in the `Arrange` step of your Pact test.
  ///
  ///     myMockService.given("a user exists")
  ///                  .uponReceiving("a request for users")
  ///                  .withRequest(method:.GET, path: "/users")
  ///                  .willRespondWith(status: 200,
  ///                                   headers: [ /* ... */ ],
  ///                                   body: [ /* ...DSL... */ ])
  ///
  /// - Parameter status: The status code of your provider's response
  /// - Parameter headers: A Dictionary representing the return headers
  /// - Parameter body: An object representing the body of your Provider's response
  /// - Returns: An `Interaction` object
  ///
  @objc(willRespondWithHTTPStatus: headers: body:)
  @discardableResult
  public func willRespondWith(status: Int,
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

  ///
  @objc
  func payload() -> [String: Any] {
    var payload: [String: Any] = ["description": testDescription,
                                  "request": request,
                                  "response": response ]
    if let providerState = providerState {
      payload["providerState"] = providerState
    }
    return payload
  }

  // MARK: - Private

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
