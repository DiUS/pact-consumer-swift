import Foundation

public struct Animal: Codable {
  public let name: String
  public let type: String
  public let dob: String?
  public let legs: Int?

  private enum CodingKeys: String, CodingKey {
    case name
    case type
    case dob = "dateOfBirth"
    case legs
  }
}

///
/// The API Client (Consumer) that is calling an API Service (Provider)
/// This is our simplified implementation of the network layer that we want to test.
/// We test our own code. Pact Mock Service acts as our (perhaps not yet live) Provider
/// and while we're running the tests, Pact creates a contract for us. That contract
/// should be shared with the Provider in order to confirm our expectations of how the
/// service will behave (our Pact tests) is met on the Provider side. The Provider
/// should set up their own tests that test their code against the contract our tests generate.
///
open class AnimalServiceClient {

  fileprivate let baseUrl: String

  public init(baseUrl : String) {
    self.baseUrl = baseUrl
  }

  ///
  /// Get all alligators
  ///
  /// Calls either succes that takes an Array<Animal>, or NSError on failure as a closure
  ///
  open func getAlligators(_ success: @escaping (Array<Animal>) -> Void, failure: @escaping (NSError?) -> Void) {
    request(
      urlString: "\(baseUrl)/alligators"
    ) { [unowned self] data, response, error in
      guard error == nil else { failure(error as NSError?); return }
      guard let data = data else { failure(self.prepareError(error)); return }

      do {
        let alligators = try JSONDecoder().decode(Array<Animal>.self, from: data)
        success(alligators)
      } catch {
        failure(self.prepareError(error))
      }
    }
  }

  ///
  /// Get all alligators by adding HTTP headers in the request
  ///
  /// - parameter authToken: A string representing Authorization string (eg: Bearer Token)
  /// Calls either succes that takes an Array<Animal>, or NSError on failure as a closure
  ///
  open func getSecureAlligators(authToken: String, success: @escaping (Array<Animal>) -> Void, failure: @escaping (NSError?) -> Void) {
    request(
      urlString: "\(baseUrl)/alligators",
      headers: ["Authorization": authToken]
    ) { data, response, error in
      guard error == nil else { failure(error as NSError?); return }
      guard let data = data else { failure(self.prepareError(error)); return }

      do {
        let secureAligators = try JSONDecoder().decode(Array<Animal>.self, from: data)
        success(secureAligators)
      } catch {
        failure(self.prepareError(error))
      }
    }

  }

  ///
  /// Get a specific alligator by `id`
  ///
  /// Calls either succes that takes an Array<Animal>, or NSError on failure as a closure
  ///
  open func getAlligator(_ id: Int, success: @escaping (Animal) -> Void, failure: @escaping (NSError?) -> Void) {
    request(
      urlString: "\(baseUrl)/alligators/\(id)"
    ) { data, response, error in
      guard error == nil else { failure(error as NSError?); return }
      guard let data = data else { failure(self.prepareError(error)); return }

      do {
        let alligator = try JSONDecoder().decode(Animal.self, from: data)
        success(alligator)
      } catch {
        failure(self.prepareError(error))
      }
    }
  }

  ///
  /// Get a list of Animals that live in an environment
  ///
  /// Calls closure with Array<Animal> as parameter
  ///
  /// - parameter live: A string representing the environment where an Animal lives (eg: "water")
  ///
  open func findAnimals(live: String, response: @escaping ([Animal]) -> Void) {
    request(
      urlString: "\(baseUrl)/animals",
      queryParameters: ["live": live]
    ) { data, requestResponse, error in
      guard let data = data else {
        response([]);
        return
      }

      do {
        let debugging = String(decoding: data, as: UTF8.self)
        debugPrint(debugging)
        let animals = try JSONDecoder().decode(Array<Animal>.self, from: data)
        response(animals)
      } catch {
        response([])
      }
    }

  }

  ///
  /// Define what animal an alligator eats
  ///
  /// - parameter animal: A String representing an animal as food to an alligator (eg: "Pigeon")
  ///
  open func eat(animal: String, success: @escaping () -> Void, error: @escaping (Int) -> Void) {
    request(
      urlString: "\(baseUrl)/alligator/eat",
      method: .patch,
      bodyParameters: ["type": animal]
    ) { data, response, responseError in
      if let response = response as? HTTPURLResponse {
        (200..<400).contains(response.statusCode) ? success() : error(response.statusCode)
      } else {
        error(500)
      }
    }
  }

  ///
  /// Removes an animal from alligators menu
  ///
  /// - parameter animal: A String representing an animal as food to an alligator (eg: "Giraffe")
  ///
  open func wontEat(animal: String, success: @escaping () -> Void, error: @escaping (Int) -> Void) {
    request(
      urlString: "\(baseUrl)/alligator/eat",
      method: .delete,
      bodyParameters: ["type": animal]
    ) { data, response, responseError in
      if let response = response as? HTTPURLResponse {
        (200..<400).contains(response.statusCode) ? success() : error(response.statusCode)
      } else {
        error(500)
      }
    }
  }

  ///
  /// Lists all the animals on alligators menu
  ///
  /// Calls closure with Array<Animal> as parameter
  ///
  open func eats(_ success: @escaping ([Animal]) -> Void) {
    request(
      urlString: "\(baseUrl)/alligator/eat"
    ) { data, response, responseError in
      guard let data = data else { success([]); return }

      do {
        let alligators = try JSONDecoder().decode(Array<Animal>.self, from: data)
        success(alligators)
      } catch {
        success([])
      }
    }
  }

}

fileprivate extension AnimalServiceClient {

  ///
  /// A helper method that prepares an error object
  ///
  /// - parameter error: The error object called in the completion by URLSession
  ///
  /// - returns: NSError
  ///
  func prepareError(_ error: Error?) -> NSError {
    return NSError(domain: "alligators", code: 1, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Error", value: error.debugDescription, comment: "")])
  }

  ///
  /// A copy of HTTPMethod from PactConsumerSwift as a demonstration for this test purpouse.
  ///
  enum HTTPMethod: String {
    case get    = "GET"
    case post   = "POST"
    case put    = "PUT"
    case patch  = "PATCH"
    case delete = "DELETE"
  }

  ///
  /// This is a very bad implementation of URLRequest that is used for this particular test purpose only!
  /// When implementing your Network Layer, you should do it properly and look elsewhere for a better example.
  /// Perhaps maybe in the `/Sources/` folder of this project.
  ///
  func request(
    urlString: String,
    headers: [String: String]? = nil,
    method: HTTPMethod = .get,
    bodyParameters: [String: String]? = nil,
    queryParameters: [String: String]? = nil,
    completion: @escaping (_ _data: Data?, _ response: URLResponse?, _ error: Error?) -> Void
    ) {
    guard let url = URL(string: urlString) else { fatalError("Could not create a URL request with \(urlString)") }
    var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 1.0)
    request.httpMethod = method.rawValue

    if let headers = headers {
      request.allHTTPHeaderFields = headers
    }

    if let bodyParameters = bodyParameters {
      do {
        let data = try JSONSerialization.data(withJSONObject: bodyParameters)
        request.httpBody = data

        if request.value(forHTTPHeaderField: "Content-Type") == nil {
          request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
      } catch {
        fatalError("Could not JSON Serialise bodyParameters!")
      }
    }

    if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
      let urlParameters = queryParameters,
      !urlParameters.isEmpty {
      urlComponents.queryItems = [URLQueryItem]()

      _ = urlParameters.map { key, value -> Void in
        urlComponents
          .queryItems?
          .append(URLQueryItem(name: key,
                               value: "\(value)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)))
      }
      request.url = urlComponents.url
    }

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
      completion(data, response, error)
    }

    task.resume()
  }

}
