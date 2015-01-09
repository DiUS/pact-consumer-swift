import Foundation
import Alamofire

public class MockService {
  private let provider: String
  private let consumer: String
  public let url: String
  public let port: Int
  private var interactions: [Interaction] = []
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
        return .POST
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
    
    var URLRequest: NSURLRequest {
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

  public init(provider: String, consumer: String, url: String = "http://localhost", port: Int = 1234) {
    self.provider = provider
    self.consumer = consumer
    self.url = url
    self.port = port
    Router.baseURLString = baseUrl
  }

  public func given(providerState: String) -> Interaction {
    var interaction = Interaction().given(providerState)
    interactions.append(interaction)
    return interaction
  }

  public func uponReceiving(description: String) -> Interaction {
    var interaction = Interaction().uponReceiving(description)
    interactions.append(interaction)
    return interaction
  }

  public func run(testFunction: (cleanup:() -> Request) -> Void) {
    clean().response { (_, _, _, error) in
      println(error)
      self.setup().response { (_, _, _, error) in
        println(error)
        testFunction { () in
          self.verify().response { (_, _, _, error) in
            println(error)
            self.write()
          }
        }
      }
    }
  }

  func clean() -> Request {
    return Alamofire.request(Router.Clean()).validate()
  }
  
  func setup () -> Request {
//    for interaction in interactions {
//      Alamofire.request(Router.Setup(interaction.asDictionary())).validate().response { (_, _, _, error) in
//        println(error)
//      }
//    }

//    interactions.removeAll()
    return Alamofire.request(Router.Setup(interactions[0].asDictionary())).validate()
  }
  
  func verify() -> Request {
    return Alamofire.request(Router.Verify()).validate()
  }
  
  func write() {
    Alamofire.request(Router.Write([ "consumer": [ "name": consumer ], "provider": [ "name": provider ] ])).validate().response { (_, _, _, error) in
      println(error)
    }
  }
  
}