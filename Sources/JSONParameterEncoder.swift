import Foundation

public struct JSONParameterEncoder: ParameterEncoder {
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
