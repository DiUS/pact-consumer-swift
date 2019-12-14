import Foundation

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
      case .clean,
           .setup:
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

  // MARK: - Interface

  func setup(_ interactions: [Interaction], completion: @escaping (Result<Void, NSError>) -> Void) {
    clean { result in
      switch result {
      case .success:
        self.setupInteractions(interactions) { result in
          switch result {
          case .success:
            completion(.success(()))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func verify(provider: String, consumer: String, completion: @escaping (Result<Void, NSError>) -> Void) {
    verifyInteractions { result in
      switch result {
      case .success:
        self.write(provider: provider, consumer: consumer) { result in
          switch result {
          case .success:
            completion(.success(()))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

}

// MARK: - Private

fileprivate extension PactVerificationService {

  func clean(completion: @escaping (Result<Void, NSError>) -> Void) {
    performNetworkRequest(for: Router.clean) { result in
      switch result {
      case .success:
        completion(.success(()))
      case .failure(let error):
        completion(.failure(self.error(with: error.localizedDescription)))
      }
    }
  }

  func verifyInteractions(completion: @escaping (Result<Void, NSError>) -> Void) {
    self.performNetworkRequest(for: Router.verify) { result in
      switch result {
      case .success:
        completion(.success(()))
      case .failure(let error):
        completion(.failure(self.error(with: error.localizedDescription)))
      }
    }
  }

  func write(provider: String, consumer: String, completion: @escaping (Result<String, NSError>) -> Void) {
    let payload = [
      "consumer": ["name": consumer],
      "provider": ["name": provider]
    ]

    self.performNetworkRequest(for: Router.write(payload)) { result in
      switch result {
      case .success(let successString):
        completion(.success(successString))
      case .failure(let error):
        completion(.failure(self.error(with: error.localizedDescription)))
      }
    }
  }

  func setupInteractions (_ interactions: [Interaction], completion: @escaping (Result<String, NSError>) -> Void) {
    let payload: [String: Any] = ["interactions": interactions.map({ $0.payload() }),
                                  "example_description": "description"]

    self.performNetworkRequest(for: Router.setup(payload)) { result in
      switch result {
      case .success(let successString):
        completion(.success(successString))
      case .failure(let error):
        completion(.failure(self.error(with: error.localizedDescription)))
      }
    }
  }

}

// MARK: - Networking without Promises

private extension PactVerificationService {

  private var session: URLSession {
    URLSession(configuration: URLSessionConfiguration.ephemeral)
  }

  func error(with message: String) -> NSError {
    NSError(
      domain: "",
      code: 0,
      userInfo: [
        NSLocalizedDescriptionKey: NSLocalizedString(
          "Error",
          value: message,
          comment: ""
        )
      ]
    )
  }

  func error(from data: Data) -> NSError {
    NSError(
      domain: "",
      code: 0,
      userInfo: [
        NSLocalizedDescriptionKey: NSLocalizedString(
          "Error",
          value: "\(String(data: data, encoding: .utf8) ?? "Failed to cast response Data into String")",
          comment: ""
        )
      ]
    )
  }

  func performNetworkRequest(for router: Router, completion: @escaping (Result<String, URLSession.APIServiceError>) -> Void) {
    do {
      let dataTask = try session.dataTask(with: router.asURLRequest()) { result in
        switch result {
        case .success(let (response, data)):
          guard let statusCode = (response as? HTTPURLResponse)?.statusCode, 200..<299 ~= statusCode else {
            completion(.failure(.invalidResponse(self.error(from: data))))
            return
          }
          guard let responseString = String(data: data, encoding: .utf8) else {
            completion(.failure(.noData))
            return
          }
          completion(.success(responseString))

        case .failure(let error):
          completion(.failure(.apiError(error)))
        }
      }
      dataTask.resume()
    } catch {
      DispatchQueue.main.async {
        completion(.failure(.invalidEndpoint))
      }
    }
  }

}

// MARK: - Foundation Extensions

extension URLSession {

  public enum APIServiceError: Error {
    case apiError(Error)
    case invalidEndpoint
    case invalidResponse(Error)
    case noData
    case decodeError
  }

  func dataTask(with url: URLRequest, result: @escaping (Result<(URLResponse, Data), Error>) -> Void) -> URLSessionDataTask {
    return dataTask(with: url) { (data, response, error) in
      guard error == nil else {
        result(.failure(error!))
        return
      }

      guard let response = response, let data = data else {
        let error = NSError(domain: "error", code: 0, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Error", value: "No response or missing expected data", comment: "")]) //swiftlint:disable:this line_length
        result(.failure(error))
        return
      }

      result(.success((response, data)))
    }
  }

}

extension URLSession.APIServiceError: LocalizedError {

  public var localizedDescription: String {
    switch self {
    case .invalidResponse(let error),
         .apiError(let error):
      return error.localizedDescription
    default:
      return ""
    }
  }

}
