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
      (_, _, result) in
      if result.isSuccess {
        if let jsonResult = result.value as? Dictionary<String, String> {
          let alligator = Animal(name: jsonResult["name"]!, type: jsonResult["type"]!)
          success(alligator)
        } else {
          failure(result.value as? NSError)
        }
      }
    }
  }

  public func findAnimals(live live: String, response: ([Animal]) -> Void) {
    Alamofire.request(.GET, "\(baseUrl)/animals", parameters: [ "live": live])
    .responseJSON {
      (_, _, result) in
      if result.isSuccess {
        if let jsonResult = result.value as? Array<Dictionary<String, String>> {
          var alligators : [Animal] = []
          for alligator in jsonResult {
            alligators.append(Animal(name: alligator["name"]!, type: alligator["type"]!))
          }
          response(alligators)
        }
      }
    }
  }

  public func eat(animal animal: String, success: () -> Void, error: (Int) -> Void) {
    Alamofire.request(.PATCH, "\(baseUrl)/alligator/eat", parameters: [ "type" : animal ], encoding: .JSON)
    .responseString { (thing, urlResponse, response) in
      if response.isFailure {
        error(urlResponse!.statusCode)
      } else {
        success()
      }
    }
  }

  public func wontEat(animal animal: String, success: () -> Void, error: (Int) -> Void) {
    Alamofire.request(.DELETE, "\(baseUrl)/alligator/eat", parameters: [ "type" : animal ], encoding: .JSON)
    .responseJSON { (_, urlResponse, response) in
      if response.isFailure {
        error(urlResponse!.statusCode)
      } else {
        success()
      }
    }
  }

  public func eats(success: ([Animal]) -> Void) {
    Alamofire.request(.GET, "\(baseUrl)/alligator/eat")
    .responseJSON { (_, _, response) in
      if response.isSuccess {
        if let jsonResult = response.value as? Array<Dictionary<String, String>> {
          var animals: [Animal] = []
          for alligator in jsonResult {
            animals.append(Animal(name: alligator["name"]!, type: alligator["type"]!))
          }
          success(animals)
        }
      }
    }
  }
}