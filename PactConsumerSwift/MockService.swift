import Foundation
import Alamofire

public enum VerificationResult {
  case PASSED
  case FAILED
}

public class MockService {
  private let provider: String
  private let consumer: String
  public let pactVerificationService: PactVerificationService
  private var interactions: [Interaction] = []
  public var baseUrl: String {
    get {
        return pactVerificationService.baseUrl
    }
  }

  public init(provider: String, consumer: String, pactVerificationService: PactVerificationService = PactVerificationService()) {
    self.provider = provider
    self.consumer = consumer
    self.pactVerificationService = pactVerificationService
  }

  public func given(providerState: String) -> Interaction {
    var interaction = Interaction().given(providerState)
    interactions.append(interaction)
    return interaction
  }

  public func uponReceiving(description: String) -> Interaction {
    var interaction = Interaction().uponReceiving(description)
    interactions.append(interaction)
    return interaction
  }

  public func run(testFunction: (complete: () -> Void) -> Void, result: (VerificationResult) -> Void) -> Void {
    self.pactVerificationService.clean(success: { () in
      self.pactVerificationService.setup(self.interactions, success: { () in
        testFunction { () in
          self.pactVerificationService.verify(success: { () in
            self.pactVerificationService.write(provider: self.provider, consumer: self.consumer, success: { () in
              result(VerificationResult.PASSED)
              return
            }, failure: { result(VerificationResult.FAILED) })
            return
          }, failure: { result(VerificationResult.FAILED) })
          return
        }
        return
      }, failure: { result(VerificationResult.FAILED) })
      return
    }, failure: { result(VerificationResult.FAILED) } )
  }
  
}