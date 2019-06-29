import Foundation
import BrightFutures

open class PactVerificationService {

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
  func setup(_ interactions: [Interaction]) -> Future<String, NSError> {
    let promise = Promise<String, NSError>()

    self.clean()
      .onSuccess { _ in
        promise.completeWith(self.setupInteractions(interactions))
      }
      .onFailure { error in
        promise.failure(error)
    }

    return promise.future
  }

  ///
  /// Verifies the interactions between your Consumer and Provider
  ///
  func verify(provider: String, consumer: String, completion: @escaping (PactResult<Void>) -> Void) {
    self
      .verifyInteractions { result in
        switch result {
        case .success:
          _ = self.write(provider: provider, consumer: consumer) { result in
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

  // MARK: - Fileprivate

  fileprivate func clean() -> Future<String, NSError> {
    let promise = Promise<String, NSError>()

    networkManager
      .clean { [unowned self] result in
        self.handleResponse(promise)(result)
    }

    return promise.future
  }

  fileprivate func setupInteractions (_ interactions: [Interaction]) -> Future<String, NSError> {
    let promise = Promise<String, NSError>()

    let parameters: [String: Any] = ["interactions": interactions.map({ $0.payload() }),
                                     "example_description": "description"]

    networkManager
      .setup(parameters) { [unowned self] result in
        self.handleResponse(promise)(result)
    }

    return promise.future
  }

  fileprivate func verifyInteractions(_ completion: @escaping (PactResult<Void>) -> Void) {
    networkManager
      .verify { result in
        switch result {
        case .success:
          completion(.success(()))
        case .failure(let error):
          completion(.failure(error))
        }
    }
  }

  fileprivate func write(provider: String, consumer: String, completion: @escaping (PactResult<Void>) -> Void) {
    let parameters: [String: [String: String]] = ["consumer": [ "name": consumer ],
                                                  "provider": [ "name": provider ]]

    networkManager
      .write(parameters) { result in
        switch result {
        case .success:
          completion(.success(()))
        case .failure(let error):
          completion(.failure(error))
        }
      }
  }

  // MARK: - Helpers

  fileprivate func failWithError(
    _ error: String,
    code: Int = 0,
    domain: String = "",
    comment: String = ""
    ) -> NSError {
    let userInfo = [NSLocalizedDescriptionKey: NSLocalizedString("Error", value: error, comment: comment)]
    return NSError(domain: domain, code: code, userInfo: userInfo)
  }

  fileprivate func handleResponse(_ promise: Promise<String, NSError>) -> NetworkCallResultCompletion {
    return { result in
      switch result {
      case .success(let resultString):
        promise.success(resultString)
      case .failure(let error):
        promise.failure(self.failWithError(error.localizedDescription, code: 0, domain: "Verification Service", comment: ""))
      }
    }
  }
}
