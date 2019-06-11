import Foundation

public struct Animal {
  public let name: String
  public let type: String
  public let dob: String?
  public let legs: Int?
}

open class AnimalServiceClient {
  fileprivate let baseUrl: String
  private let session = URLSession(configuration: URLSessionConfiguration.ephemeral)

  public init(baseUrl : String) {
    self.baseUrl = baseUrl
  }

  open func getAlligators(_ success: @escaping (Array<Animal>) -> Void, failure: @escaping (NSError?) -> Void) {
    self.performRequest("\(baseUrl)/alligators") { jsonObject, nsError in
      if let jsonArray = jsonObject as? Array<[String: AnyObject]> {
        success(jsonArray.map { animal -> Animal in
          return Animal(
            name: animal["name"] as! String,
            type: animal["type"] as! String,
            dob: animal["dateOfBirth"] as? String,
            legs: animal["legs"] as? Int)
        })
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
    self.performRequest("\(baseUrl)/alligators", headers: ["Authorization": authToken]) { jsonObject, nsError in
      if let jsonArray = jsonObject as? Array<[String: AnyObject]> {
        success(jsonArray.map { animal -> Animal in
          return Animal(
            name: animal["name"] as! String,
            type: animal["type"] as! String,
            dob: animal["dateOfBirth"] as? String,
            legs: animal["legs"] as? Int)
        })
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
    self.performRequest("\(baseUrl)/alligators/\(id)") { jsonObject, nsError in
      if let jsonResult = jsonObject as? Dictionary<String, AnyObject> {
        let alligator = Animal(
          name: jsonResult["name"] as! String,
          type: jsonResult["type"] as! String,
          dob: jsonResult["dateOfBirth"] as? String,
          legs: jsonResult["legs"] as? Int)
        success(alligator)
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
    self.performRequest("\(baseUrl)/animals?live=\(liveEncoded)") { jsonObject, nsError in
      if let jsonResult = jsonObject as? Array<Dictionary<String, AnyObject>> {
        var alligators : [Animal] = []
        for alligator in jsonResult {
          alligators.append(Animal(
            name: alligator["name"] as! String,
            type: alligator["type"] as! String,
            dob: alligator["dateOfBirth"] as? String,
            legs: alligator["legs"] as? Int))
        }
        response(alligators)
      }
    }
  }

  open func eat(animal: String, success: @escaping () -> Void, error: @escaping (Int) -> Void) {
    self.performRequest("\(baseUrl)/alligator/eat", method: "patch", parameters: ["type": animal], isJsonResponse: false) { jsonObject, nsError in
      if let localErr = nsError {
        error(localErr.code)
      } else {
        success()
      }
    }
  }

  open func wontEat(animal: String, success: @escaping () -> Void, error: @escaping (Int) -> Void) {
    self.performRequest("\(baseUrl)/alligator/eat", method: "delete", parameters: ["type": animal]) { jsonObject, nsError in
      if let localErr = nsError {
        error(localErr.code)
      } else {
        success()
      }
    }
  }

  open func eats(_ success: @escaping ([Animal]) -> Void) {
    self.performRequest("\(baseUrl)/alligator/eat") { jsonObject, nsError in
      if let jsonResult = jsonObject as? Array<Dictionary<String, AnyObject>> {
        var animals: [Animal] = []
        for alligator in jsonResult {
          animals.append(Animal(
            name: alligator["name"] as! String,
            type: alligator["type"] as! String,
            dob: alligator["dateOfBirth"] as? String,
            legs: alligator["legs"] as? Int))
        }
        success(animals)
      }
    }
  }

  private func performRequest(_ urlString: String, headers: [String: String]? = nil, method: String = "get", parameters: [String: String]? = nil, isJsonResponse: Bool = true, completionHandler: @escaping (_ jsonObject: Any?, _ error: NSError?) -> Void) {
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
          if isJsonResponse {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            completionHandler(jsonObject, nil)
          } else {
            let stringResponse = String(data: data, encoding: .utf8)
            completionHandler(stringResponse, nil)
          }
        } catch {
          completionHandler(nil, error as NSError)
        }
      } else {
        completionHandler(nil, NSError(domain: "", code: 41, userInfo: nil))
      }
    }

    task.resume()
  }
}
