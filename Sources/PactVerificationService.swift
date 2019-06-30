import Foundation
import BrightFutures

open class PactVerificationService {

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
  ///
  public func setup(_ interactions: [Interaction]) -> Future<String, NSError> {
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
  public func verify(provider: String, consumer: String) -> Future<String, NSError> {
    let promise = Promise<String, NSError>()

    self.verifyInteractions()
      .onSuccess { _ in
        promise.completeWith(self.write(provider: provider, consumer: consumer))
      }
      .onFailure { error in
        promise.failure(error)
    }

    return promise.future
  }

  // MARK: - Fileprivate

  private func clean() -> Future<String, NSError> {
    let promise = Promise<String, NSError>()

    networkManager
      .clean { [unowned self] result in
        self.handleResponse(promise)(result)
    }

    return promise.future
  }

  private func setupInteractions (_ interactions: [Interaction]) -> Future<String, NSError> {
    let promise = Promise<String, NSError>()

    let parameters: [String: Any] = ["interactions": interactions.map({ $0.payload() }),
                                     "example_description": "description"]

    networkManager
      .setup(parameters) { [unowned self] result in
        self.handleResponse(promise)(result)
    }

    return promise.future
  }

  private func verifyInteractions() -> Future<String, NSError> {
    let promise = Promise<String, NSError>()

    networkManager
      .verify { [unowned self] result in
        self.handleResponse(promise)(result)
    }

    return promise.future
  }

  private func write(provider: String, consumer: String) -> Future<String, NSError> {
    let promise = Promise<String, NSError>()

    let parameters: [String: [String: String]] = ["consumer": [ "name": consumer ],
                                                  "provider": [ "name": provider ]]

    networkManager
      .write(parameters) { [unowned self] result in
        self.handleResponse(promise)(result)
    }

    return promise.future
  }

  // MARK: - Helpers

  private func failWithError(
    _ error: String,
    code: Int = 0,
    domain: String = "",
    comment: String = ""
    ) -> NSError {
    let userInfo = [NSLocalizedDescriptionKey: NSLocalizedString("Error", value: error, comment: comment)]
    return NSError(domain: domain, code: code, userInfo: userInfo)
  }

  private func handleResponse(_ promise: Promise<String, NSError>) -> NetworkCallResultCompletion {
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
