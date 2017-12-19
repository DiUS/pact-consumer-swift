import BrightFutures

public protocol MockServer {
  func setup(_ pact: Pact) -> Future<String, PactError>
  func verify(_ pact: Pact) -> Future<String, PactError>
  func getBaseUrl() -> String
}
