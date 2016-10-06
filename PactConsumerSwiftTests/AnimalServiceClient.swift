import Foundation
import Alamofire

public struct Animal {
  public let name: String
  public let type: String
  public let dob: String?
  public let legs: Int?
}

public class AnimalServiceClient {
    private let baseUrl: String

  public init(baseUrl : String) {
    self.baseUrl = baseUrl
  }

  public func getAlligators(success: (Array<Animal>) -> Void, failure: (NSError?) -> Void) {
    Alamofire.request(.GET, "\(baseUrl)/alligators")
    .responseJSON {
      (result) in
      if result.result.isSuccess {
        if let jsonArray = result.result.value as? Array<[String: AnyObject]> {
          success(jsonArray.map { animal -> Animal in
            return Animal(
                    name: animal["name"] as! String,
                    type: animal["type"] as! String,
                    dob: animal["dateOfBirth"] as? String,
                    legs: animal["legs"] as? Int)
          })
        } else {
          failure(result.result.value as? NSError)
        }
      }
    }
  }

  public func getAlligator(id: Int, success: (Animal) -> Void, failure: (NSError?) -> Void) {
    Alamofire.request(.GET, "\(baseUrl)/alligators/\(id)")
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

  public func findAnimals(live live: String, response: ([Animal]) -> Void) {
    Alamofire.request(.GET, "\(baseUrl)/animals", parameters: [ "live": live])
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

  public func eat(animal animal: String, success: () -> Void, error: (Int) -> Void) {
    Alamofire.request(.PATCH, "\(baseUrl)/alligator/eat", parameters: [ "type" : animal ], encoding: .JSON)
    .responseString { (response) in
      if response.result.isFailure {
        error(response.response!.statusCode)
      } else {
        success()
      }
    }
  }

  public func wontEat(animal animal: String, success: () -> Void, error: (Int) -> Void) {
    Alamofire.request(.DELETE, "\(baseUrl)/alligator/eat", parameters: [ "type" : animal ], encoding: .JSON)
    .responseJSON { (response) in
      if response.result.isFailure {
        error(response.response!.statusCode)
      } else {
        success()
      }
    }
  }

  public func eats(success: ([Animal]) -> Void) {
    Alamofire.request(.GET, "\(baseUrl)/alligator/eat")
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
