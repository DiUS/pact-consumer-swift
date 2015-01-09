import Foundation
import Alamofire

public class HelloClient {
    private let baseUrl: String

  public init(baseUrl : String) {
    self.baseUrl = baseUrl
  }

  public func sayHello(helloResponse: (String) -> Void) {
    Alamofire.request(.GET, "\(baseUrl)/sayHello")
             .responseJSON { (request, response, json, error) in
      println(request)
      println(response)
      println(error)
      if let jsonResult = json as? Dictionary<String, AnyObject> {
        helloResponse(jsonResult["reply"] as String)
      }
    }
  }
}