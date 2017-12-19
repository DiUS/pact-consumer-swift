import Foundation

public class Pact {
  let provider: String
  let consumer: String
  var interactions: [Interaction] = []

  public init(provider: String, consumer: String) {
    self.provider = provider
    self.consumer = consumer
  }

  func withInteractions(_ interactions: [Interaction]) {
    self.interactions = interactions
  }

  func payload() -> [String: Any] {
    return [ "provider": [ "name": provider],
      "consumer": [ "name": consumer],
      "interactions": interactions.map({ PactInteractionAdapter($0).adapt() }),
      "metadata": [ "pact-specification": [ "version": "2.0.0"] ]]
  }
}
