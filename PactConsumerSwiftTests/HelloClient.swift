import Foundation
import Alamofire

public class HelloClient {
  private let baseUrl = "http://google.com"

  public init() {

  }

  public func sayHello(helloResponse: (String) -> Void) {
    Alamofire.request(.GET, baseUrl)
             .response { (request, response, json, error) in
      println(request)
      println(response)
      println(error)
      helloResponse("hello")
    }
  }
}