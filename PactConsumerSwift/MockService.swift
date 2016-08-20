import Foundation
import Alamofire
import BrightFutures
import Result
import Nimble

@objc public class MockService : NSObject {
  private let provider: String
  private let consumer: String
  private let pactVerificationService: PactVerificationService
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

  @objc(run:)
  public func objcRun(testFunction: (testComplete: () -> Void) -> Void) -> Void {
    self.run(nil, line: nil, testFunction: testFunction)
  }

  public func run(file: String? = #file, line: UInt? = #line, testFunction: (testComplete: () -> Void) -> Void) -> Void {
    var complete = false
    self.pactVerificationService.setup(self.interactions).onSuccess { result in
      testFunction { () in
        self.pactVerificationService.verify(provider: self.provider, consumer: self.consumer).onSuccess { result in
          complete = true
        }.onFailure { error in
          if let fileName = file, lineNumber = line {
            fail("Error verifying pact: \(error.localizedDescription)", file: fileName, line: lineNumber)
          } else {
            fail("Error verifying pact: \(error.localizedDescription)")
          }
        }
        return
      }
      return
    }.onFailure { error in
      fail("Error setting up pact: \(error.localizedDescription)")
    }
    if let fileName = file, lineNumber = line {
      expect(fileName, line: lineNumber, expression: { complete} ).toEventually(beTrue())
    } else {
      expect(complete).toEventually(beTrue())
    }
  }
}