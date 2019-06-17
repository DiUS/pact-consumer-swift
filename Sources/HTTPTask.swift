import Foundation

public typealias HTTPHeaders = [String: String]

public enum HTTPTask {
  case request

  case requestParameters(bodyParameters: Parameters?,
    urlParameters: Parameters?)

  case requestParametersAndHeaders(bodyParameters: Parameters?,
    urlParameters: Parameters?,
    additionHeaders: HTTPHeaders?)
}
