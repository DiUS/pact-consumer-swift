import Foundation
import BrightFutures

open class PactVerificationService {
  public let url: String
  public let port: Int
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

  public init(url: String = "http://localhost", port: Int = 1234) {
    self.url = url
    self.port = port
    Router.baseURLString = baseUrl
  }

    private let session = URLSession(configuration: URLSessionConfiguration.ephemeral)

  func setup(_ interactions: [Interaction]) -> Future<String, NSError> {
    let promise = Promise<String, NSError>()
    self.clean().onSuccess { _ in
        promise.completeWith(self.setupInteractions(interactions))
    }.onFailure { error in
      promise.failure(error)
    }

    return promise.future
  }

  func verify(provider: String, consumer: String) -> Future<String, NSError> {
    let promise = Promise<String, NSError>()
    self.verifyInteractions().onSuccess { _ in
      promise.completeWith(self.write(provider: provider, consumer: consumer))
    }.onFailure { error in
      promise.failure(error)
    }

    return promise.future
  }

  fileprivate func verifyInteractions() -> Future<String, NSError> {
    let promise = Promise<String, NSError>()

    self.performNetworkRequest(for: Router.verify, promise: promise)

    return promise.future
  }

  fileprivate func write(provider: String, consumer: String) -> Future<String, NSError> {
    let promise = Promise<String, NSError>()
    let payload: [String: [String: String]] = ["consumer": ["name": consumer],
                                               "provider": ["name": provider]]

    self.performNetworkRequest(for: Router.write(payload), promise: promise)

    return promise.future
  }

  fileprivate func clean() -> Future<String, NSError> {
    let promise = Promise<String, NSError>()

    self.performNetworkRequest(for: Router.clean, promise: promise)

    return promise.future
  }

  fileprivate func setupInteractions (_ interactions: [Interaction]) -> Future<String, NSError> {
    let promise = Promise<String, NSError>()
    let payload: [String: Any] = ["interactions": interactions.map({ $0.payload() }),
                                  "example_description": "description"]

    self.performNetworkRequest(for: Router.setup(payload), promise: promise)

    return promise.future
  }

  // MARK: - Networking

  private func performNetworkRequest(for router: Router, promise: Promise<String, NSError>) {
    let task: URLSessionDataTask?
    do {
      task = try session.dataTask(with: router.asURLRequest()) { data, response, error in
        self.responseHandler(promise)(data, response, error)
      }

      task?.resume()
    } catch {
      DispatchQueue.main.async {
        // Make sure this promise fails in the future.
        promise.failure(error as NSError)
      }
    }
  }

  private func responseHandler(_ promise: Promise<String, NSError>) -> (Data?, URLResponse?, Error?) -> Void {
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
        let userInfo = [NSLocalizedDescriptionKey: NSLocalizedString("Error", value: errorMessage, comment: "")]
        promise.failure(NSError(domain: "", code: 0, userInfo: userInfo))
    }
  }
}
