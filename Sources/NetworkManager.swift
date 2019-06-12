import Foundation

typealias NetworkCallCompletion = (_ response: String?, _ error: String?) -> Void

///
/// A Network Manager service that takes the `MockAPI`
/// as the router configuration and makes calls to the
/// Pact Mock Service
///
public struct NetworkManager {

    private let router = Router<MockAPI>()

    ///
    /// Clears any previously defined interactions between
    /// your Pact client and your Pact provider by
    /// interacting with Pact Mock Service.
    ///
    /// - parameter completion: closure that is called when network call finishes
    ///
    /// - Returns: No return value
    ///
    func clean(completion: @escaping NetworkCallCompletion) {
        router.request(.clean) { data, response, error in
            self.handleStringResponse(data, response, error) { response, error in
                completion(response, error)
            }
        }
    }

    ///
    /// Verifies interactions between your Pact client and your Pact provider.
    ///
    /// - parameter completion: closure that is called when network call finishes
    ///
    /// - Returns: No return value
    ///
    func verify(completion: @escaping NetworkCallCompletion) {
        router.request(.verify) { data, response, error in
            self.handleStringResponse(data, response, error) { response, error in
                completion(response, error)
            }
        }
    }

    ///
    /// Writes the interactions between your Pact client and your Pact provider.
    ///
    /// - parameters: parameters defining the Consumer and Provider
    ///
    /// ```
    /// [ "consumer": [ "name": "My Consumer" ],
    ///   "provider": [ "name": "My App's Provider" ] ]
    /// ```
    ///
    func write(_ parameters: [String: [String: String]], completion: @escaping NetworkCallCompletion) {
        router.request(.write(parameters)) { data, response, error in
            self.handleStringResponse(data, response, error) { response, error in
                completion(response, error)
            }
        }
    }

    ///
    /// Sets up to write the Pact file, the contract, between your Pact client and your Pact provider.
    ///
    func setup(_ parameters: [String: Any], completion: @escaping NetworkCallCompletion) {
        router.request(.setup(parameters)) { data, response, error in
            self.handleStringResponse(data, response, error) { response, error in
                completion(response, error)
            }
        }
    }

    // MARK: - Private

    ///
    /// Checks for network response status code
    ///
    /// - parameter response: The response from the network call
    ///
    /// - returns: .success or .failure(String) describing the cause of error
    ///
    fileprivate func handleNetworkResponse(_ response: HTTPURLResponse) -> Result<String> {
        switch response.statusCode {
        case 200...299: return .success
        case 401, 403:  return .failure(NetworkResponse.authenticationError.rawValue)
        case 400,
             402,
             404...499: return .failure(NetworkResponse.badRequest.rawValue)
        case 500...599: return .failure(NetworkResponse.serverError.rawValue)
        case 600:       return .failure(NetworkResponse.outdated.rawValue)
        default:        return .failure(NetworkResponse.failed.rawValue)
        }
    }

    ///
    /// Checks for the response from Pact Mock Service and decodes Data? response into a `String`
    ///
    /// - parameter data: Data returned from the remote webservice
    /// - parameter response: Response object
    /// - parameter error: Error object
    /// - parameter completion: Closure that is called when response is handled
    ///
    fileprivate func handleStringResponse(
        _ data: Data?,
        _ response: URLResponse?,
        _ error: Error?,
        completion: NetworkCallCompletion
    ) {
        if error != nil { completion(nil, NetworkResponse.failed.rawValue) }

        if let response = response as? HTTPURLResponse {
            let result = self.handleNetworkResponse(response)

            switch result {
            case .success:
                guard let responseData = data else {
                    completion(nil, NetworkResponse.noData.rawValue)
                    return
                }
                completion(String(decoding: responseData, as: UTF8.self), nil)

            case .failure(let networkFailureError):
                completion(nil, networkFailureError)
            }
        }
    }
}
