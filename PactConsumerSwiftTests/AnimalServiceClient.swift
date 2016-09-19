import Foundation
import Alamofire

public struct Animal {
  public let name: String
  public let type: String
  public let dob: String?
  public let legs: Int?
}

open class AnimalServiceClient {
    fileprivate let baseUrl: String

  public init(baseUrl : String) {
    self.baseUrl = baseUrl
  }

  open func getAlligator(_ success: @escaping (Animal) -> Void, failure: @escaping (NSError?) -> Void) {
    Alamofire.request("\(baseUrl)/alligator")
    .responseJSON {
      (result) in
      if result.result.isSuccess {
        if let jsonResult = result.result.value as? Dictionary<String, AnyObject> {
          let alligator = Animal(
              name: jsonResult["name"] as! String, 
              type: jsonResult["type"] as! String, 
              dob: jsonResult["dateOfBirth"] as? String,
              legs: jsonResult["legs"] as? Int)
          success(alligator)
        } else {
          failure(result.result.value as? NSError)
        }
      }
    }
  }

  open func findAnimals(live: String, response: @escaping ([Animal]) -> Void) {
    Alamofire.request("\(baseUrl)/animals", parameters: [ "live": live])
    .responseJSON {
      (result) in
      if result.result.isSuccess {
        if let jsonResult = result.result.value as? Array<Dictionary<String, AnyObject>> {
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
  }

  open func eat(animal: String, success: @escaping () -> Void, error: @escaping (Int) -> Void) {
    Alamofire.request("\(baseUrl)/alligator/eat", method: .patch, parameters: [ "type" : animal ], encoding: JSONEncoding.default)
    .responseString { (response) in
      if response.result.isFailure {
        error(response.response!.statusCode)
      } else {
        success()
      }
    }
  }

  open func wontEat(animal: String, success: @escaping () -> Void, error: @escaping (Int) -> Void) {
    Alamofire.request("\(baseUrl)/alligator/eat", method: .delete, parameters: [ "type" : animal ], encoding: JSONEncoding.default)
    .responseJSON { (response) in
      if response.result.isFailure {
        error(response.response!.statusCode)
      } else {
        success()
      }
    }
  }

  open func eats(_ success: @escaping ([Animal]) -> Void) {
    Alamofire.request("\(baseUrl)/alligator/eat")
    .responseJSON { (response) in
      if response.result.isSuccess {
        if let jsonResult = response.result.value as? Array<Dictionary<String, AnyObject>> {
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
  }
}
