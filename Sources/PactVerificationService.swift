import Foundation

open class PactVerificationService: NSObject {

  typealias VoidHandler = (Result<Void, NSError>) -> Void
  typealias StringHandler = (Result<String, NSError>) -> Void

  public let url: String
  public let port: Int
  public let allowInsecureCertificates: Bool

  open var baseUrl: String {
    return "\(url):\(port)"
  }

  private lazy var session = {
    return URLSession(configuration: .ephemeral, delegate: self, delegateQueue: nil)
  }()

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

  public init(url: String = "http://localhost", port: Int = 1234, allowInsecureCertificates: Bool = false) {
    self.url = url
    self.port = port
    self.allowInsecureCertificates = allowInsecureCertificates

    super.init()

    Router.baseURLString = baseUrl
  }

  // MARK: - Interface

  func setup(_ interactions: [Interaction], completion: @escaping VoidHandler) {
    clean { result in
      switch result {
      case .success:
        self.setupInteractions(interactions) { result in
          self.handleResponse(result: result, completion: completion)
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
          self.handleResponse(result: result, completion: completion)
        }
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

}

// MARK: - Private

private extension PactVerificationService {

  func clean(completion: @escaping VoidHandler) {
    performNetworkRequest(for: Router.clean) { result in
      self.handleResponse(result: result, completion: completion)
    }
  }

  func setupInteractions (_ interactions: [Interaction], completion: @escaping StringHandler) {
    let payload: [String: Any] = [
      "interactions": interactions.map({ $0.payload() }),
      "example_description": "description"
    ]

    performNetworkRequest(for: Router.setup(payload)) { result in
      self.handleResponse(result: result, completion: completion)
    }
  }

  func verifyInteractions(completion: @escaping VoidHandler) {
    performNetworkRequest(for: Router.verify) { result in
      self.handleResponse(result: result, completion: completion)
    }
  }

  func write(provider: String, consumer: String, completion: @escaping StringHandler) {
     let payload = [
       "consumer": ["name": consumer],
       "provider": ["name": provider]
     ]

     performNetworkRequest(for: Router.write(payload)) { result in
       self.handleResponse(result: result, completion: completion)
     }
   }

}

// MARK: - Result handlers

private extension PactVerificationService {

  func handleResponse(result: Result<String, NSError>, completion: @escaping VoidHandler) {
    switch result {
    case .success:
      completion(.success(()))
    case .failure(let error):
      completion(.failure(error))
    }
  }

  func handleResponse(result: Result<String, URLSession.APIServiceError>, completion: @escaping VoidHandler) {
    switch result {
    case .success:
      completion(.success(()))
    case .failure(let error):
      completion(.failure(NSError.prepareWith(message: error.localizedDescription)))
    }
  }

  func handleResponse(result: Result<String, URLSession.APIServiceError>, completion: @escaping StringHandler) {
    switch result {
    case .success(let resultString):
      completion(.success(resultString))
    case .failure(let error):
      completion(.failure(NSError.prepareWith(message: error.localizedDescription)))
    }
  }

}

// MARK: - Network request handler

private extension PactVerificationService {

  func performNetworkRequest(for router: Router, completion: @escaping (Result<String, URLSession.APIServiceError>) -> Void) {
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
    } catch let error {
      completion(.failure(.dataTaskError(error)))
    }
  }

}

// MARK: - Type Extensions

private extension NSError {

  static func prepareWith(userInfo: [String: Any]) -> NSError {
    return NSError(domain: "error", code: 0, userInfo: userInfo)
  }

  static func prepareWith(message: String) -> NSError {
    return NSError(domain: "error", code: 0, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Error", value: message, comment: "")]) //swiftlint:disable:this line_length
  }

  static func prepareWith(data: Data) -> NSError {
    return NSError(domain: "error", code: 0, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Error", value: "\(String(data: data, encoding: .utf8) ?? "Failed to cast response Data into String")", comment: "")]) //swiftlint:disable:this line_length
  }

}

private extension URLSession {

  enum APIServiceError: Error {
    case apiError(Error)
    case dataTaskError(Error)
    case decodeError
    case invalidEndpoint
    case invalidResponse(Error)
    case noData
  }

  func dataTask(with url: URLRequest, result: @escaping (Result<(URLResponse, Data), Error>) -> Void) -> URLSessionDataTask {
    return dataTask(with: url) { (data, response, error) in
      guard error == nil else {
        result(.failure(error!))
        return
      }

      guard let response = response, let data = data else {
        let error = NSLocalizedString("Error", value: "No response or missing expected data", comment: "")
        result(.failure(NSError.prepareWith(userInfo: [NSLocalizedDescriptionKey: error])))
        return
      }

      result(.success((response, data)))
    }
  }

}

extension URLSession.APIServiceError: LocalizedError {

  public var localizedDescription: String {
    switch self {
    case .apiError(let error),
         .dataTaskError(let error),
         .invalidResponse(let error):
      return error.localizedDescription
    case .decodeError:
      return URLSession.APIServiceError.decodeError.localizedDescription
    case .invalidEndpoint:
      return URLSession.APIServiceError.invalidEndpoint.localizedDescription
    case .noData:
      return URLSession.APIServiceError.noData.localizedDescription
    }
  }

}

extension PactVerificationService: URLSessionDelegate {

  public func urlSession(
    _ session: URLSession,
    didReceive challenge: URLAuthenticationChallenge,
    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
  ) {
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
