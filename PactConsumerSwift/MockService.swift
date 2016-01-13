import Foundation
import Alamofire
import BrightFutures
import Result

@objc public enum PactVerificationResult: Int {
  case Passed, Failed
}

@objc public class MockService : NSObject {
  public typealias PactDoneCallback = (PactVerificationResult) -> ()
  private let provider: String
  private let consumer: String
  private let done: PactDoneCallback
  private let pactVerificationService: PactVerificationService
  private var interactions: [Interaction] = []

  public var baseUrl: String {
    get {
        return pactVerificationService.baseUrl
    }
  }

  public init(provider: String, consumer: String, done: PactDoneCallback, pactVerificationService: PactVerificationService) {
    self.provider = provider
    self.consumer = consumer
    self.done = done
    self.pactVerificationService = pactVerificationService
  }

  @objc(initWithProvider: consumer: done:)
  public convenience init(provider: String, consumer: String, done: PactDoneCallback) {
    self.init(provider: provider, consumer: consumer, done: done, pactVerificationService: PactVerificationService())
  }

  public func given(providerState: String) -> Interaction {
    let interaction = Interaction().given(providerState)
    interactions.append(interaction)
    return interaction
  }

  @objc(uponReceiving:)
  public func uponReceiving(description: String) -> Interaction {
    let interaction = Interaction().uponReceiving(description)
    interactions.append(interaction)
    return interaction
  }

  @objc public func run(testFunction: (testComplete: () -> Void) -> Void) -> Void {
    self.pactVerificationService.setup(self.interactions).onSuccess { result in
      testFunction { () in
        self.pactVerificationService.verify(provider: self.provider, consumer: self.consumer).onSuccess { result in
          self.done(PactVerificationResult.Passed)
        }.onFailure { error in
          print(error)
          self.done(PactVerificationResult.Failed)
        }
        return
      }
      return
    }.onFailure { error in self.done(PactVerificationResult.Failed) }
  }
}