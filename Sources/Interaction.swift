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
  @objc
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
    response = Response(status: status, headers: headers, body: body)
    return self
  }

  func payload() -> [String: Any] {
    return PactInteractionAdapter(self).adapt()
  }
}
