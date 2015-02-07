import Foundation
import Alamofire


@objc public class MockService : NSObject {
  private let provider: String
  private let consumer: String
  public let pactVerificationService: PactVerificationService
  private var interactions: [Interaction] = []
  public var baseUrl: String {
    get {
        return pactVerificationService.baseUrl
    }
  }

  public init(provider: String, consumer: String, pactVerificationService: PactVerificationService) {
    self.provider = provider
    self.consumer = consumer
    self.pactVerificationService = pactVerificationService
  }

  @objc(initWithProvider: consumer:)
  public convenience init(provider: String, consumer: String) {
    self.init(provider: provider, consumer: consumer, pactVerificationService: PactVerificationService())
  }

  public func given(providerState: String) -> Interaction {
    var interaction = Interaction().given(providerState)
    interactions.append(interaction)
    return interaction
  }

  @objc(uponReceiving:)
  public func uponReceiving(description: String) -> Interaction {
    var interaction = Interaction().uponReceiving(description)
    interactions.append(interaction)
    return interaction
  }

  @objc public func run(testFunction: (complete: () -> Void) -> Void, result: (PactVerificationResult) -> Void) -> Void {
    self.pactVerificationService.clean().andThen { result in
      self.pactVerificationService.setup(self.interactions).andThen {
        result in
        testFunction { () in
          self.pactVerificationService.verify().andThen { result in
            self.pactVerificationService.write(provider: self.provider, consumer: self.consumer)
            return
          }
          return
        }
        return
      }
      return
    }.onSuccess { response in
      result(PactVerificationResult.Passed)
    }.onFailure { error in
      result(PactVerificationResult.Failed)
    }
  }
}