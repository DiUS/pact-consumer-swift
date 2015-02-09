import Foundation
import Alamofire

public class HelloClient {
    private let baseUrl: String

  public init(baseUrl : String) {
    self.baseUrl = baseUrl
  }

  public func sayHello(helloResponse: (String) -> Void) {
    Alamofire.request(.GET, "\(baseUrl)/sayHello")
    .responseJSON {
      (request, response, json, error) in
      println(request)
      println(response)
      println(error)
      if let jsonResult = json as? Dictionary<String, AnyObject> {
        helloResponse(jsonResult["reply"] as String)
      }
    }
  }

  public func findFriendsByAgeAndChild(friendsResponse: (Array<String>) -> Void) {
    Alamofire.request(.GET, "\(baseUrl)/friends", parameters: [ "age" : "30", "child" : "Mary" ] )
    .responseJSON { (request, response, json, error) in
      println(request)
      println(response)
      println(error)
      if let jsonResult = json as? Dictionary<String, AnyObject> {
        friendsResponse(jsonResult["friends"] as Array)
      }
    }
  }
  
  public func unfriendMe(successResponse: (Dictionary<String, String>) -> Void, errorResponse: (Int) -> Void) {
    Alamofire.request(.PUT, "\(baseUrl)/unfriendMe" )
      .responseJSON { (request, response, json, error) in
        println(request)
        println(response)
        println(error)
        if let errorVal = error {
          errorResponse(response!.statusCode)
        }
        if let jsonResult = json as? Dictionary<String, AnyObject> {
          successResponse(jsonResult as Dictionary<String, String>)
        }
    }
  }
}