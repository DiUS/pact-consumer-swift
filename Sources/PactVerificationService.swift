import Foundation

open class PactVerificationService {
  typealias CompletionHandler = (VerificationResult<Error>) -> Void

  enum VerificationResult<Error> {
    case success
    case failure(Error)
  }

  var baseUrl: String {
    return "\(PactMockServiceAPI.url):\(PactMockServiceAPI.port)"
  }

  private var networkManager: NetworkManager!

  ///
  /// Networking service that talks to your Pact-Mock-Service (eg: pact-ruby-standalone)
  /// - parameter url: The `url` where your Pact-Mock-Service is running
  /// - parameter port: The port on which your Pact-Mock-Service is listening
  /// - parameter networkLogging: set to `true` for network call and response logging
  /// - parameter networkManager: DI option for your specific NetworkManager
  ///
  public init(
    url: String = "http://localhost",
    port: Int = 1234,
    networkLogging: Bool = false,
    networkManager: NetworkManager? = nil
  ) {
    PactMockServiceAPI.url = url
    PactMockServiceAPI.port = port
    PactMockServiceAPI.enableNetworkLogging = networkLogging

    self.networkManager = networkManager ?? NetworkManager()
  }

  ///
  /// Calls Pact-Mock-Service and sets the interactions between your Consumer and Provider
  /// - parameter interactions: Interactions between consumer and provider to be set up
  ///
  func setup(_ interactions: [Interaction], done: @escaping CompletionHandler) {
    self
      .clean { result in
        switch result {
        case .success:
          self.setupInteractions(interactions) { result in
            switch result {
            case .success:
              done(.success)
            case .failure(let error):
              done(.failure(error))
            }
          }
        case .failure(let error):
          done(.failure(error))
        }
      }
  }

  ///
  /// Verifies the interactions between your Provider and your Consumer
  /// - parameter provider: Name of the API provider (eg: "Identity Service")
  /// - parameter consumer: Name of the API consumer (eg: "Our Awesome App")
  ///
  func verify(provider: String, consumer: String, verified: @escaping CompletionHandler) {
    self
      .verifyInteractions { result in
        switch result {
        case .success:
          self.write(provider: provider, consumer: consumer) { result in
            switch result {
            case .success:
              verified(.success)
            case .failure(let error):
              verified(.failure(error))
            }
          }
        case .failure(let error):
          verified(.failure(error))
        }
      }
  }
}

fileprivate extension PactVerificationService {

  func clean(_ done: @escaping CompletionHandler) {
    networkManager
      .clean { [unowned self] result in
        self.resultHandler(result, handler: done)
      }
  }

  func setupInteractions(_ interactions: [Interaction], done: @escaping CompletionHandler) {
    let parameters: [String: Any] = ["interactions": interactions.map({ $0.payload() }),
                                     "example_description": "description"]

    networkManager
      .setup(parameters) { [unowned self] result in
        self.resultHandler(result, handler: done)
      }
  }

  func verifyInteractions(_ done: @escaping CompletionHandler) {
    networkManager
      .verify { [unowned self] result in
        self.resultHandler(result, handler: done)
      }
  }

  func write(provider: String, consumer: String, done: @escaping CompletionHandler) {
    let parameters: [String: [String: String]] = ["consumer": [ "name": consumer ],
                                                  "provider": [ "name": provider ]]

    networkManager
      .write(parameters) { [unowned self] result in
        self.resultHandler(result, handler: done)
      }
  }

  // MARK: - Helpers

  func resultHandler(_ result: NetworkResult<String>, handler: CompletionHandler) {
    switch result {
    case .success:
      handler(.success)
    case .failure(let error):
      handler(.failure(error))
    }
  }
}
