import Foundation

open class PactVerificationService {

  typealias VoidHandler = (Result<Void, NSError>) -> Void
  typealias StringHandler = (Result<String, NSError>) -> Void
  typealias StringResult = Result<String, URLSession.APIServiceError>

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

  func setup(_ interactions: [Interaction], completion: @escaping VoidHandler) {
    clean { result in
      switch result {
      case .success:
        self.setupInteractions(interactions) { result in
          self.handle(result: result, completion: completion)
        }
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func verify(provider: String, consumer: String, completion: @escaping VoidHandler) {
    verifyInteractions { result in
      switch result {
      case .success:
        self.write(provider: provider, consumer: consumer) { result in
          self.handle(result: result, completion: completion)
        }
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

}

// MARK: - Private

fileprivate extension PactVerificationService {

  func clean(completion: @escaping VoidHandler) {
    performNetworkRequest(for: Router.clean) { result in
      self.handle(result: result, completion: completion)
    }
  }

  func setupInteractions (_ interactions: [Interaction], completion: @escaping StringHandler) {
    let payload: [String: Any] = [
      "interactions": interactions.map({ $0.payload() }),
      "example_description": "description"
    ]

    performNetworkRequest(for: Router.setup(payload)) { result in
      self.handle(result: result, completion: completion)
    }
  }

  func verifyInteractions(completion: @escaping VoidHandler) {
    performNetworkRequest(for: Router.verify) { result in
      self.handle(result: result, completion: completion)
    }
  }

  func write(provider: String, consumer: String, completion: @escaping StringHandler) {
     let payload = [
       "consumer": ["name": consumer],
       "provider": ["name": provider]
     ]

     performNetworkRequest(for: Router.write(payload)) { result in
       self.handle(result: result, completion: completion)
     }
   }

}

// MARK: - Result handlers

fileprivate extension PactVerificationService {

  func handle(result: Result<String, NSError>, completion: @escaping VoidHandler) {
    switch result {
    case .success:
      completion(.success(()))
    case .failure(let error):
      completion(.failure(error))
    }
  }

  func handle(result: StringResult, completion: @escaping VoidHandler) {
    switch result {
    case .success:
      completion(.success(()))
    case .failure(let error):
      completion(.failure(NSError.prepareWith(message: error.localizedDescription)))
    }
  }

  func handle(result: StringResult, completion: @escaping StringHandler) {
    switch result {
    case .success(let resultString):
      completion(.success(resultString))
    case .failure(let error):
      completion(.failure(NSError.prepareWith(message: error.localizedDescription)))
    }
  }

}

// MARK: - Network request handler

fileprivate extension PactVerificationService {

  var session: URLSession {
    URLSession(configuration: URLSessionConfiguration.ephemeral)
  }

  func performNetworkRequest(for router: Router, completion: @escaping (StringResult) -> Void) {
    do {
      let dataTask = try session.dataTask(with: router.asURLRequest()) { result in
        switch result {
        case .success(let (response, data)):
          guard let statusCode = (response as? HTTPURLResponse)?.statusCode, 200..<299 ~= statusCode else {
            completion(.failure(.invalidResponse(NSError.prepareWith(data: data))))
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
      completion(.failure(.invalidEndpoint))
    }
  }

}
