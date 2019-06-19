import Foundation

public struct JSONParameterEncoder: ParameterEncoder {

  /// Encode URLRequest parameters into JSON object
  ///
  /// - parameter urlRequest: URLRequest being updated and sets header value `Content-Type: application/json`
  /// - parameter parameters: JSON parameters to be serialized into Data object and added to the `urlRequest` as `.httpBody`
  ///
  public func encode(urlRequest: inout URLRequest, with parameters: Parameters) throws {
    do {
      let jsonAsData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
      urlRequest.httpBody = jsonAsData
      urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
    } catch {
      throw NetworkError.encodingFailed
    }
  }

}
