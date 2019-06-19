import Foundation

public struct URLParameterEncoder: ParameterEncoder {

  /// Encode an URLRequest with parameters for URL components
  ///
  /// - parameter urlRequest: URLRequest being changed
  /// - parameter parameters: URL components to be percentage encoded with allowed characters set to `.urlHostAllowed`
  ///
  public func encode(urlRequest: inout URLRequest, with parameters: Parameters) throws {
    guard let url = urlRequest.url else {
      throw NetworkError.missingURL
    }

    if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false), !parameters.isEmpty {
      urlComponents.queryItems = [URLQueryItem]()

      _ = parameters.map { key, value -> Void in
        urlComponents
          .queryItems?
          .append(URLQueryItem(name: key,
                               value: "\(value)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)))
      }
      urlRequest.url = urlComponents.url
    }

    if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
      urlRequest.setValue("application/x-www-form-urlencoded; charset=utf-8",
                          forHTTPHeaderField: "Content-Type")
    }
  }

}
