import OHHTTPStubs

class VerifiableHttpStub {
  public var requestExecuted = false
  public var requestBody: String?
  private var requestStub: RubyMockServiceRequest

  public init(requestStub: RubyMockServiceRequest) {
    self.requestStub = requestStub
  }

  func stubWithResponse(responseCode: Int32, response: String) {
    stub(condition: isHost("localhost") && requestStub.path && requestStub.method) { request in
      if let body = request.ohhttpStubs_httpBody {
        self.requestBody = String(data: body, encoding: .utf8)
      }
      self.requestExecuted = true
      let stubData: Data? = response.data(using: .utf8)
      return OHHTTPStubsResponse(data: stubData!, statusCode:responseCode, headers:nil)
    }
  }

  func stubWithError(errorMessage: String) {
    let userInfo = [NSLocalizedDescriptionKey: NSLocalizedString("Error", value: errorMessage, comment: "")]
    let error = NSError(domain: NSURLErrorDomain, code: URLError.notConnectedToInternet.rawValue, userInfo: userInfo)

    stub(condition: isHost("localhost") && requestStub.path && requestStub.method) { request in
      self.requestExecuted = true
      return OHHTTPStubsResponse(error: error)
    }
  }
}

enum RubyMockServiceRequest {
  case cleanInteractions
  case setupInteractions
  case verifyInteractions
  case writePact

  var method: OHHTTPStubsTestBlock {
    switch self {
    case .cleanInteractions:
      return isMethodDELETE()
    case .setupInteractions:
      return isMethodPUT()
    case .verifyInteractions:
      return isMethodGET()
    case .writePact:
      return isMethodPOST()
    }
  }

  var path: OHHTTPStubsTestBlock {
    switch self {
    case .cleanInteractions:
      return isPath("/interactions")
    case .setupInteractions:
      return isPath("/interactions")
    case .verifyInteractions:
      return isPath("/interactions/verification")
    case .writePact:
      return isPath("/pact")
    }
  }
}

struct RubyPactMockServiceStub {
  var cleanStub: VerifiableHttpStub = VerifiableHttpStub(requestStub: RubyMockServiceRequest.cleanInteractions)
  var setupInteractionsStub: VerifiableHttpStub = VerifiableHttpStub(requestStub: RubyMockServiceRequest.setupInteractions)
  var verifyInteractionsStub: VerifiableHttpStub = VerifiableHttpStub(requestStub: RubyMockServiceRequest.verifyInteractions)
  var writePactStub: VerifiableHttpStub = VerifiableHttpStub(requestStub: RubyMockServiceRequest.writePact)

  @discardableResult
  func clean(responseCode: Int32,
             response: String) -> RubyPactMockServiceStub {
    self.cleanStub.stubWithResponse(responseCode: responseCode, response: response)
    return self
  }

  func cleanWithError(errorMessage: String) {
    self.cleanStub.stubWithError(errorMessage: errorMessage)
  }

  @discardableResult
  func setupInteractions(responseCode: Int32,
                         response: String) -> RubyPactMockServiceStub {
    self.setupInteractionsStub.stubWithResponse(responseCode: responseCode, response: response)
    return self
  }

  @discardableResult
  func verifyInteractions(responseCode: Int32,
                          response: String) -> RubyPactMockServiceStub {
    self.verifyInteractionsStub.stubWithResponse(responseCode: responseCode, response: response)
    return self
  }

  @discardableResult
  func writePact(responseCode: Int32,
                 response: String) -> RubyPactMockServiceStub {
    self.writePactStub.stubWithResponse(responseCode: responseCode, response: response)
    return self
  }

  func reset() {
    OHHTTPStubs.removeAllStubs()
  }
}
