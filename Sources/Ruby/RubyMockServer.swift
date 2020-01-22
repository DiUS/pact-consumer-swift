import Foundation
import BrightFutures

open class PactVerificationService: NSObject, MockServer {
  public let url: String
  public let port: Int
  public let allowInsecureCertificates: Bool

  open var baseUrl: String {
    return "\(url):\(port)"
  }

    enum Router {
    static var baseURLString = "http://example.com"

    case clean
    case setup([String: Any])
    case verify
    case write([String: [String: String]])

    var method: String {
      switch self {
      case .clean:
        return "delete"
      case .setup:
        return "put"
      case .verify:
        return "get"
      case .write:
        return "post"
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
      guard let url = URL(string: Router.baseURLString) else { throw NSError(domain: "", code: 1, userInfo: nil) }
      var urlRequest = URLRequest(url: url.appendingPathComponent(path))
      urlRequest.httpMethod = method
      urlRequest.setValue("true", forHTTPHeaderField: "X-Pact-Mock-Service")

      switch self {
      case .setup(let parameters):
        return try jsonEncode(urlRequest, with: parameters)
      case .write(let parameters):
        return try jsonEncode(urlRequest, with: parameters)
      default:
        return urlRequest
      }
    }

    private func jsonEncode(_ request: URLRequest, with parameters: [String: Any]) throws -> URLRequest {
      var urlRequest = request
      let data = try JSONSerialization.data(withJSONObject: parameters, options: [])

      urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

      urlRequest.httpBody = data
      return urlRequest
    }
  }

  public init(url: String = "http://localhost", port: Int = 1234, allowInsecureCertificates: Bool = false) {
    self.url = url
    self.port = port
    self.allowInsecureCertificates = allowInsecureCertificates

    super.init()
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
      promise.failure(error)
    }
    return promise.future
  }

  public func verify(_ pact: Pact) -> Future<String, PactError> {
    let promise = Promise<String, PactError>()
    self.verifyInteractions().onSuccess { _ in
      promise.completeWith(self.write(provider: pact.provider, consumer: pact.consumer))
    }.onFailure { error in
      promise.failure(error)
    }
    return promise.future
  }

  private func verifyInteractions() -> Future<String, PactError> {
    let promise = Promise<String, PactError>()

    self.performNetworkRequest(for: Router.verify, promise: promise)

    return promise.future
  }

  private func write(provider: String, consumer: String) -> Future<String, PactError> {
    let promise = Promise<String, PactError>()
    let payload: [String: [String: String]] = ["consumer": ["name": consumer],
                                               "provider": ["name": provider]]

    self.performNetworkRequest(for: Router.write(payload), promise: promise)

    return promise.future
  }

  private func clean() -> Future<String, PactError> {
    let promise = Promise<String, PactError>()

    self.performNetworkRequest(for: Router.clean, promise: promise)

    return promise.future
  }

  private func setupInteractions (_ interactions: [Interaction]) -> Future<String, PactError> {
    let promise = Promise<String, PactError>()
    let payload: [String: Any] = ["interactions": interactions.map({ RubyInteractionAdapter($0).adapt() }),
                                  "example_description": "description"]

    self.performNetworkRequest(for: Router.setup(payload), promise: promise)

    return promise.future
  }

  // MARK: - Networking

  private lazy var session = {
    return URLSession(configuration: .ephemeral, delegate: self, delegateQueue: nil)
  }()

  private func performNetworkRequest(for router: Router, promise: Promise<String, PactError>) {
    let task: URLSessionDataTask?
    do {
      task = try session.dataTask(with: router.asURLRequest()) { data, response, error in
        self.responseHandler(promise)(data, response, error)
      }

      task?.resume()
    } catch {
      DispatchQueue.main.async {
        // Make sure this promise fails in the future.
        promise.failure(.executionError(error.localizedDescription))
      }
    }
  }

  private func responseHandler(_ promise: Promise<String, PactError>) -> ((Data?, URLResponse?, Error?) -> Void) {
    return { data, response, error in
      if let data = data,
         let response = response as? HTTPURLResponse,
         let stringValue = String(data: data, encoding: .utf8),
         (200..<300).contains(response.statusCode) {
          promise.success(stringValue)
          return
      }

      let errorMessage: String
      if let errorBody = data {
        errorMessage = "\(String(data: errorBody, encoding: String.Encoding.utf8)!)"
      } else {
        errorMessage = error?.localizedDescription ?? "Unknown error"
      }
        // this is problem!
        // check again solution of existing project
      promise.failure(.executionError(errorMessage))

    }
  }
}

extension PactVerificationService: URLSessionDelegate {
  public func urlSession(_ session: URLSession,
                         didReceive challenge: URLAuthenticationChallenge,
                         completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
    guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
        allowInsecureCertificates,
        let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.performDefaultHandling, nil)
            return
    }

    let proposedCredential = URLCredential(trust: serverTrust)
    completionHandler(.useCredential, proposedCredential)
  }
}
