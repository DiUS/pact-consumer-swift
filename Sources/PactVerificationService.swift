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

            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }

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
    private var setupTask: URLSessionDataTask?
    private var verifyTask: URLSessionDataTask?
    private var cleanTask: URLSessionDataTask?
    private var writeTask: URLSessionDataTask?

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

    do {
        verifyTask = try
            session.dataTask(with: Router.verify.asURLRequest()) { data, response, error in
                defer { self.verifyTask = nil }

                self.requestHandler(promise)(data, response, error)
        }

        verifyTask?.resume()
    } catch {
        DispatchQueue.main.async {
            // Make sure this promise fails in the future.
            promise.failure(error as NSError)
        }
    }

    return promise.future
  }

  fileprivate func write(provider: String, consumer: String) -> Future<String, NSError> {
    let promise = Promise<String, NSError>()

    do {
        writeTask = try
            session.dataTask(with: Router.write(["consumer": [ "name": consumer ],
                                                 "provider": [ "name": provider ]]
                ).asURLRequest()) { data, response, error in
                defer { self.writeTask = nil }

                self.requestHandler(promise)(data, response, error)
        }

        writeTask?.resume()
    } catch {
        DispatchQueue.main.async {
            // Make sure this promise fails in the future.
            promise.failure(error as NSError)
        }
    }

    return promise.future
  }

  fileprivate func clean() -> Future<String, NSError> {
    let promise = Promise<String, NSError>()

    do {
        cleanTask = try session.dataTask(with: Router.clean.asURLRequest()) { data, response, error in
            defer { self.cleanTask = nil }

            self.requestHandler(promise)(data, response, error)
        }

        cleanTask?.resume()
    } catch {
        DispatchQueue.main.async {
            // Make sure this promise fails in the future.
            promise.failure(error as NSError)
        }
    }

    return promise.future
  }

  fileprivate func setupInteractions (_ interactions: [Interaction]) -> Future<String, NSError> {
    let promise = Promise<String, NSError>()
    let payload: [String: Any] = ["interactions": interactions.map({ $0.payload() }),
                                  "example_description": "description"]

    do {
        setupTask = try session.dataTask(with: Router.setup(payload).asURLRequest()) { data, response, error in
            defer { self.setupTask = nil }

            self.requestHandler(promise)(data, response, error)
        }

        setupTask?.resume()
    } catch {
        DispatchQueue.main.async {
            // Make sure this promise fails in the future.
            promise.failure(error as NSError)
        }
    }

    return promise.future
  }

  private func requestHandler(_ promise: Promise<String, NSError>) -> (Data?, URLResponse?, Error?) -> Void {
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
