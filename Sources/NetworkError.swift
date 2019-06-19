import Foundation

public enum NetworkError: Error {
  /// Error when object being sent to PactMockServiceAPI can not be encoded
  case encodingFailed

  /// Error when encoding URL parameters is missing a URL
  case missingURL

  /// Error when URLResponse from PactMockServiceAPI contains no data
  case noData

  /// Generic error containing the contents of the passed in error
  case failed(Error)
}
