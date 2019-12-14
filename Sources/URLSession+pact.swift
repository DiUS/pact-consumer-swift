import Foundation

extension URLSession {

  public enum APIServiceError: Error {
    case apiError(Error)
    case invalidEndpoint
    case invalidResponse(Error)
    case noData
    case decodeError
  }

  func dataTask(with url: URLRequest, result: @escaping (Result<(URLResponse, Data), Error>) -> Void) -> URLSessionDataTask {
    return dataTask(with: url) { (data, response, error) in
      guard error == nil else {
        result(.failure(error!))
        return
      }

      guard let response = response, let data = data else {
        result(.failure(NSError.prepareWith(userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Error", value: "No response or missing expected data", comment: "")]))) //swiftlint:disable:this line_length
        return
      }

      result(.success((response, data)))
    }
  }

}

extension URLSession.APIServiceError: LocalizedError {

  public var localizedDescription: String {
    switch self {
    case .invalidResponse(let error),
         .apiError(let error):
      return error.localizedDescription
    default:
      return "Unknown error"
    }
  }

}
