import Foundation

public struct Animal: Decodable {
  public let name: String
  public let type: String
  public let dob: String?
  public let legs: Int?

  enum CodingKeys: String, CodingKey {
    case name
    case type
    case dob = "dateOfBirth"
    case legs
  }
}

open class AnimalServiceClient: NSObject, URLSessionDelegate {
  fileprivate let baseUrl: String

  public init(baseUrl : String) {
    self.baseUrl = baseUrl
  }

  // MARK: -

  open func getAlligators(_ success: @escaping (Array<Animal>) -> Void, failure: @escaping (NSError?) -> Void) {
    self.performRequest("\(baseUrl)/alligators", decoder: decodeAnimals) { animals, nsError in
      if let animals = animals {
        success(animals)
      } else {
        if let error = nsError {
          failure(error)
        } else {
          failure(NSError(domain: "", code: 42, userInfo: nil))
        }
      }
    }
  }

  open func getSecureAlligators(authToken: String, success: @escaping (Array<Animal>) -> Void, failure: @escaping (NSError?) -> Void) {
    self.performRequest("\(baseUrl)/alligators", headers: ["Authorization": authToken], decoder: decodeAnimals) { animals, nsError in
      if let animals = animals {
        success(animals)
      } else {
        if let error = nsError {
          failure(error)
        } else {
          failure(NSError(domain: "", code: 42, userInfo: nil))
        }
      }
    }
  }

  open func getAlligator(_ id: Int, success: @escaping (Animal) -> Void, failure: @escaping (NSError?) -> Void) {
    self.performRequest("\(baseUrl)/alligators/\(id)", decoder: decodeAnimal) { animal, nsError in
      if let animal = animal {
        success(animal)
      } else {
        if let error = nsError {
          failure(error)
        } else {
          failure(NSError(domain: "", code: 42, userInfo: nil))
        }
      }
    }
  }

  open func findAnimals(live: String, response: @escaping ([Animal]) -> Void) {
    let liveEncoded = live.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    self.performRequest("\(baseUrl)/animals?live=\(liveEncoded)", decoder: decodeAnimals) { animals, nsError in
      if let animals = animals {
        response(animals)
      }
    }
  }

  open func eat(animal: String, success: @escaping () -> Void, error: @escaping (Int) -> Void) {
    self.performRequest("\(baseUrl)/alligator/eat", method: "patch", parameters: ["type": animal], decoder: decodeString) { string, nsError in
      if let localErr = nsError {
        error(localErr.code)
      } else {
        success()
      }
    }
  }

  open func wontEat(animal: String, success: @escaping () -> Void, error: @escaping (Int) -> Void) {
    self.performRequest("\(baseUrl)/alligator/eat", method: "delete", parameters: ["type": animal], decoder: decodeAnimals) { animals, nsError in
      if let localErr = nsError {
        error(localErr.code)
      } else {
        success()
      }
    }
  }

  open func eats(_ success: @escaping ([Animal]) -> Void) {
    self.performRequest("\(baseUrl)/alligator/eat", decoder: decodeAnimals) { animals, nsError in
      if let animals = animals {
        success(animals)
      }
    }
  }

  // MARK: - URLSessionDelegate

  public func urlSession(
    _ session: URLSession,
    didReceive challenge: URLAuthenticationChallenge,
    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
  ) {
    guard
      challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
      challenge.protectionSpace.host.contains("localhost"),
      let serverTrust = challenge.protectionSpace.serverTrust
       else {
        completionHandler(.performDefaultHandling, nil)
        return
    }

    let credential = URLCredential(trust: serverTrust)
    completionHandler(.useCredential, credential)
  }

  // MARK: - Networking and Decoding

  private lazy var session = {
    URLSession(configuration: .ephemeral, delegate: self, delegateQueue: .main)
  }()

  private func performRequest<T: Decodable>(_ urlString: String,
                              headers: [String: String]? = nil,
                              method: String = "get",
                              parameters: [String: String]? = nil,
                              decoder: @escaping (_ data: Data) throws -> T,
                              completionHandler: @escaping (_ response: T?, _ error: NSError?) -> Void
    ) {
    var request = URLRequest(url: URL(string: urlString)!)
    request.httpMethod = method
    if let headers = headers {
      request.allHTTPHeaderFields = headers
    }
    if let parameters = parameters,
      let data = try? JSONSerialization.data(withJSONObject: parameters, options: []) {
      request.addValue("application/json", forHTTPHeaderField: "Content-Type")
      request.httpBody = data
    }

    let task = self.session.dataTask(with: request) { data, response, error in
      if let error = error {
        completionHandler(nil, error as NSError)
        return
      }

      if let data = data,
        let response = response as? HTTPURLResponse,
        (200..<300).contains(response.statusCode) {
        do {
          let result = try decoder(data)
          completionHandler(result, nil)
        } catch {
          completionHandler(nil, error as NSError)
        }
      } else {
        completionHandler(nil, NSError(domain: "", code: 41, userInfo: nil))
      }
    }

    task.resume()
  }

  private func decodeAnimal(_ data: Data) throws -> Animal {
    let decoder = JSONDecoder()
    return try decoder.decode(Animal.self, from: data)
  }

  private func decodeAnimals(_ data: Data) throws -> [Animal] {
      let decoder = JSONDecoder()
      return try decoder.decode([Animal].self, from: data)
  }

  private func decodeString(_ data: Data) throws -> String {
    guard let result = String(data: data, encoding: .utf8) else {
      throw NSError(domain: "", code: 63, userInfo: nil)
    }
    return result
  }
}
