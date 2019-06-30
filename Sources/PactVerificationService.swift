import Foundation

open class PactVerificationService {

  enum VerificationResult<Error> {
    case success
    case failure(Error)
  }

  typealias CompletionHandler = (VerificationResult<Error>) -> Void

  open var baseUrl: String {
    return "\(PactMockServiceAPI.url):\(PactMockServiceAPI.port)"
  }

  var networkManager: NetworkManager!

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
  /// Verifies the interactions between your Consumer and Provider
  ///
  func verify(provider: String, consumer: String, verified: @escaping CompletionHandler) {
    self
      .verifyInteractions { result in
        switch result {
        case .success:
          _ = self.write(provider: provider, consumer: consumer) { result in
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

  // MARK: - Fileprivate BrightFuture

  fileprivate func clean(_ done: @escaping CompletionHandler) {
    networkManager
      .clean { result in
        switch result {
        case .success:
          done(.success)
        case .failure(let error):
          done(.failure(error))
        }
      }
  }

  fileprivate func setupInteractions(_ interactions: [Interaction], done: @escaping CompletionHandler) {
    let parameters: [String: Any] = ["interactions": interactions.map({ $0.payload() }),
                                     "example_description": "description"]

    networkManager
      .setup(parameters) { result in
        switch result {
        case .success:
          done(.success)
        case .failure(let error):
          done(.failure(error))
        }
      }
  }

  fileprivate func verifyInteractions(_ verified: @escaping CompletionHandler) {
    networkManager
      .verify { result in
        switch result {
        case .success:
          verified(.success)
        case .failure(let error):
          verified(.failure(error))
        }
      }
  }

  fileprivate func write(provider: String, consumer: String, done: @escaping CompletionHandler) {
    let parameters: [String: [String: String]] = ["consumer": [ "name": consumer ],
                                                  "provider": [ "name": provider ]]

    networkManager
      .write(parameters) { result in
        switch result {
        case .success:
          done(.success)
        case .failure(let error):
          done(.failure(error))
        }
      }
  }
}
