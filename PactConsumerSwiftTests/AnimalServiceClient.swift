import Foundation
import Alamofire

public struct Animal {
  public let name: String
  public let type: String
}

public class AnimalServiceClient {
    private let baseUrl: String

  public init(baseUrl : String) {
    self.baseUrl = baseUrl
  }

  public func getAlligator(success: (Animal) -> Void, failure: (NSError?) -> Void) {
    Alamofire.request(.GET, "\(baseUrl)/alligator")
    .responseJSON {
      (_, _, json, error) in
      if let jsonResult = json as? Dictionary<String, String> {
        let alligator = Animal(name: jsonResult["name"]!, type: jsonResult["type"]!)
        success(alligator)
      } else {
        failure(error)
      }
    }
  }

  public func findAnimals(#live: String, response: ([Animal]) -> Void) {
    Alamofire.request(.GET, "\(baseUrl)/animals", parameters: [ "live": live])
    .responseJSON {
      (_, _, json, error) in
      if let jsonResult = json as? Array<Dictionary<String, String>> {
        var alligators : [Animal] = []
        for alligator in jsonResult {
          alligators.append(Animal(name: alligator["name"]!, type: alligator["type"]!))
        }
        response(alligators)
      }
    }
  }

  public func eat(#animal: String, success: () -> Void, error: (Int) -> Void) {
    Alamofire.request(.PATCH, "\(baseUrl)/alligator/eat", parameters: [ "type" : animal ], encoding: .JSON)
    .responseJSON { (_, response, json, errorResponse) in
      if let errorVal = errorResponse {
        error(response!.statusCode)
      } else {
        success()
      }
    }
  }

  public func wontEat(#animal: String, success: () -> Void, error: (Int) -> Void) {
    Alamofire.request(.DELETE, "\(baseUrl)/alligator/eat", parameters: [ "type" : animal ], encoding: .JSON)
    .responseJSON { (_, response, json, errorResponse) in
      if let errorVal = errorResponse {
        error(response!.statusCode)
      } else {
        success()
      }
    }
  }

  public func eats(success: ([Animal]) -> Void) {
    Alamofire.request(.GET, "\(baseUrl)/alligator/eat")
    .responseJSON { (_, response, json, errorResponse) in
      if let jsonResult = json as? Array<Dictionary<String, String>> {
        var animals: [Animal] = []
        for alligator in jsonResult {
          animals.append(Animal(name: alligator["name"]!, type: alligator["type"]!))
        }
        success(animals)
      }
    }
  }
}