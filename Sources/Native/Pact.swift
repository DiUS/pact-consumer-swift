import Foundation

open class Pact {
  fileprivate let provider: String
  fileprivate let consumer: String
  fileprivate var interactions: [PactInteraction] = []

  public init(provider: String, consumer: String) {
    self.provider = provider
    self.consumer = consumer
  }

  open func withInteractions(_ interactions: [PactInteraction]) {
    self.interactions = interactions
  }

  open func payload() -> [String: Any] {
    return [ "provider": [ "name": provider],
      "consumer": [ "name": consumer],
      "interactions": interactions.map({ $0.payload() }),
      "metadata": [ "pact-specification": [ "version": "1.0.0"] ]]
  }
}
