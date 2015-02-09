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

  @objc public func run(testFunction: (complete: () -> Void) -> Void, verification: (PactVerificationResult) -> Void) -> Void {
    self.pactVerificationService.clean().onSuccess { result in
      self.pactVerificationService.setup(self.interactions).onSuccess {
        result in
        testFunction { () in
          self.pactVerificationService.verify().onSuccess { result in
            self.pactVerificationService.write(provider: self.provider, consumer: self.consumer)
            return
          }.onSuccess { response in
            verification(PactVerificationResult.Passed)
          }.onFailure { error in
            verification(PactVerificationResult.Failed)
          }
          return
        }
        return
      }.onFailure { error in
        verification(PactVerificationResult.Failed)
      }
      return
    }.onFailure { error in
      verification(PactVerificationResult.Failed)
    }
  }
}