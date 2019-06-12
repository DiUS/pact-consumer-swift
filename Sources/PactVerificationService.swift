import Foundation
import BrightFutures

open class PactVerificationService {

    open var baseUrl: String {
        return "\(MockAPI.url):\(MockAPI.port)"
    }

    var networkManager: NetworkManager!

    public init(
        url: String = "http://localhost",
        port: Int = 1234,
        networkManager: NetworkManager? = nil
    ) {
        MockAPI.url = url
        MockAPI.port = port

        self.networkManager = networkManager ?? NetworkManager()
    }

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

    func verify(provider: String, consumer: String) -> Future<String, NSError> {
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

    fileprivate func clean() -> Future<String, NSError> {
        let promise = Promise<String, NSError>()

        networkManager
            .clean { [unowned self] response, error in
                self.handleResponse(promise)(response, error)
        }

        return promise.future
    }

    fileprivate func setupInteractions (_ interactions: [Interaction]) -> Future<String, NSError> {
        let promise = Promise<String, NSError>()

        let parameters: [String: Any] = ["interactions": interactions.map({ $0.payload() }),
                                         "example_description": "description"]

        networkManager
            .setup(parameters) { [unowned self] response, error in
                self.handleResponse(promise)(response, error)
        }

        return promise.future
    }

    fileprivate func verifyInteractions() -> Future<String, NSError> {
        let promise = Promise<String, NSError>()

        networkManager
            .verify { [unowned self] response, error in
                self.handleResponse(promise)(response, error)
        }

        return promise.future
    }

    fileprivate func write(provider: String, consumer: String) -> Future<String, NSError> {
        let promise = Promise<String, NSError>()

        let parameters: [String: [String: String]] = ["consumer": [ "name": consumer ],
                                                      "provider": [ "name": provider ]]

        networkManager
            .write(parameters) { [unowned self] response, error in
                self.handleResponse(promise)(response, error)
        }

        return promise.future
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

    fileprivate func handleResponse(_ promise: Promise<String, NSError>) -> NetworkCallCompletion {
        return { response, error in
            if let error = error {
                promise.failure(self.failWithError(error))
            } else {
                promise.success(response!)
            }
        }
    }
}
