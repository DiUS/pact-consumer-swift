import Foundation
import Alamofire
import BrightFutures

open class RubyMockServer: MockServer {
  let url: String
  let port: Int

  open var baseUrl: String {
    return "\(url):\(port)"
  }

  enum Router: URLRequestConvertible {
    static var baseURLString = "http://example.com"

    case clean
    case setup([String: Any])
    case verify
    case write([String: [String: String]])

    var method: HTTPMethod {
      switch self {
      case .clean:
        return .delete
      case .setup:
        return .put
      case .verify:
        return .get
      case .write:
        return .post
      }
    }

    var path: String {
      switch self {
      case .clean:
        return "/interactions"
      case .setup:
        return "/interactions"
      case .verify:
        return "/interactions/verification"
      case .write:
        return "/pact"
      }
    }

    // MARK: URLRequestConvertible
    func asURLRequest() throws -> URLRequest {
      let url = try Router.baseURLString.asURL()
      var urlRequest = URLRequest(url: url.appendingPathComponent(path))
      urlRequest.httpMethod = method.rawValue
      urlRequest.setValue("true", forHTTPHeaderField: "X-Pact-Mock-Service")

      switch self {
      case .setup(let parameters):
        return try JSONEncoding.default.encode(urlRequest, with: parameters)
      case .write(let parameters):
        return try JSONEncoding.default.encode(urlRequest, with: parameters)
      default:
        return urlRequest
      }
    }
  }

  public init(url: String = "http://localhost", port: Int = 1234) {
    self.url = url
    self.port = port
    Router.baseURLString = baseUrl
  }

  public func getBaseUrl() -> String {
    return baseUrl
  }

  public func setup(_ pact: Pact) -> Future<String, PactError> {
    let promise = Promise<String, PactError>()
    self.clean().onSuccess { _ in
        promise.completeWith(self.setupInteractions(pact.interactions))
    }.onFailure { error in
      promise.failure(.setupError(error.localizedDescription))
    }
    return promise.future
  }

  public func verify(_ pact: Pact) -> Future<String, PactError> {
    let promise = Promise<String, PactError>()
    self.verifyInteractions().onSuccess { _ in
      promise.completeWith(self.write(provider: pact.provider, consumer: pact.consumer))
    }.onFailure { error in
      promise.failure(.missmatches(error.localizedDescription))
    }
    return promise.future
  }

  fileprivate func verifyInteractions() -> Future<String, PactError> {
    let promise = Promise<String, PactError>()
    Alamofire.request(Router.verify)
    .validate()
    .responseString { response in self.requestHandler(promise)(response) }
    return promise.future
  }

  fileprivate func write(provider: String, consumer: String) -> Future<String, PactError> {
    let promise = Promise<String, PactError>()
    Alamofire.request(Router.write(["consumer": [ "name": consumer ],
                                    "provider": [ "name": provider ]]))
    .validate()
    .responseString { response in self.requestHandler(promise)(response) }
    return promise.future
  }

  fileprivate func clean() -> Future<String, PactError> {
    let promise = Promise<String, PactError>()

    Alamofire.request(Router.clean)
    .validate()
    .responseString { response in self.requestHandler(promise)(response) }

    return promise.future
  }

  fileprivate func setupInteractions (_ interactions: [Interaction]) -> Future<String, PactError> {
    let promise = Promise<String, PactError>()
    let payload: [String: Any] = ["interactions": interactions.map({ RubyInteractionAdapter($0).adapt() }),
                                  "example_description": "description"]
    Alamofire.request(Router.setup(payload))
              .validate()
              .responseString { response in self.requestHandler(promise)(response) }

    return promise.future
  }

  func requestHandler(_ promise: Promise<String, PactError>) -> (DataResponse<String>) -> Void {
    return { response in
      switch response.result {
      case .success(let responseValue):
        promise.success(responseValue)
      case .failure(let error):
        let errorMessage: String
        if let errorBody = response.data {
          errorMessage = "\(String(data: errorBody, encoding: String.Encoding.utf8)!)"
        } else {
          errorMessage = error.localizedDescription
        }
        promise.failure(.executionError(errorMessage))
      }
    }
  }
}
