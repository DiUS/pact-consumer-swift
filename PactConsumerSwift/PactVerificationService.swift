import Foundation
import Alamofire
import BrightFutures

public class PactVerificationService {
  public let url: String
  public let port: Int
  public var baseUrl: String {
    get {
      return "\(url):\(port)"
    }
  }
  
  enum Router: URLRequestConvertible {
    static var baseURLString = "http://example.com"
    
    case Clean()
    case Setup([String: AnyObject])
    case Verify()
    case Write([String: AnyObject])
    
    var method: Alamofire.Method {
      switch self {
      case .Clean:
        return .DELETE
      case .Setup:
        return .PUT
      case .Verify:
        return .GET
      case .Write:
        return .POST
      }
    }
    
    var path: String {
      switch self {
      case .Clean:
        return "/interactions"
      case .Setup:
        return "/interactions"
      case .Verify:
        return "/interactions/verification"
      case .Write:
        return "/pact"
      }
    }
    
    var URLRequest: NSMutableURLRequest {
      let URL = NSURL(string: Router.baseURLString)!
      let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
      mutableURLRequest.HTTPMethod = method.rawValue
      mutableURLRequest.setValue("true", forHTTPHeaderField: "X-Pact-Mock-Service")
      
      switch self {
      case .Setup(let parameters):
        return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0
      case .Write(let parameters):
        return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0
      default:
        return mutableURLRequest
      }
    }
  }
  
  public init(url: String = "http://localhost", port: Int = 1234) {
    self.url = url
    self.port = port
    Router.baseURLString = baseUrl
  }
  
  func setup (interactions: [Interaction]) -> Future<String, NSError> {
    let promise = Promise<String, NSError>()
    self.clean().onSuccess {
      result in
        promise.completeWith(self.setupInteractions(interactions))
    }.onFailure { error in
      promise.failure(error)
    }
    
    return promise.future
  }
  
  func verify(provider provider: String, consumer: String) -> Future<String, NSError> {
    let promise = Promise<String, NSError>()
    self.verifyInteractions().onSuccess {
      result in
      promise.completeWith(self.write(provider: provider, consumer: consumer))
    }.onFailure { error in
      promise.failure(error)
    }

    return promise.future
  }

  private func verifyInteractions() -> Future<String, NSError> {
    let promise = Promise<String, NSError>()
    Alamofire.request(Router.Verify())
    .validate()
    .responseString { response in self.requestHandler(promise)(response) }
    
    return promise.future
  }

  private func write(provider provider: String, consumer: String) -> Future<String, NSError> {
    let promise = Promise<String, NSError>()

    Alamofire.request(Router.Write([ "consumer": [ "name": consumer ], "provider": [ "name": provider ] ]))
    .validate()
    .responseString { response in self.requestHandler(promise)(response) }

    return promise.future
  }

  private func clean() -> Future<String, NSError> {
    let promise = Promise<String, NSError>()

    Alamofire.request(Router.Clean())
    .validate()
    .responseString { response in self.requestHandler(promise)(response) }

    return promise.future
  }

  private func setupInteractions (interactions: [Interaction]) -> Future<String, NSError> {
    let promise = Promise<String, NSError>()
    let payload: [ String : AnyObject ] = [ "interactions" : interactions.map({ $0.payload() }), "example_description" : "description"]
    Alamofire.request(Router.Setup(payload))
              .validate()
              .responseString { response in self.requestHandler(promise)(response) }

    return promise.future
  }
    
  func requestHandler(promise: Promise<String, NSError>) -> (Response<String, NSError>) -> Void {
    return { response in
      switch response.result {
      case .Success(let responseValue):
        promise.success(responseValue)
      case .Failure(let error):
        let errorMessage : String;
        if let errorBody = response.data {
          errorMessage = "\(NSString(data: errorBody, encoding: NSUTF8StringEncoding)!)"
        } else {
          errorMessage = error.localizedDescription
        }
        let userInfo = [ NSLocalizedDescriptionKey :  NSLocalizedString("Unauthorized", value: errorMessage, comment: "")]
        promise.failure(NSError(domain: error.domain, code: error.code, userInfo: userInfo))
      }
    }
  }
}
