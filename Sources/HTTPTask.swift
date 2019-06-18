import Foundation

public typealias HTTPHeaders = [String: String]

public enum HTTPTask {
  case request

  case requestWithParameters(bodyParameters: Parameters?,
    urlParameters: Parameters?,
    additionHeaders: HTTPHeaders?)
}
