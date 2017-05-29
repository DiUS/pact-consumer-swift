import Foundation
import Alamofire
import BrightFutures
import Result
import Nimble

@objc open class MockService: NSObject {
  fileprivate let provider: String
  fileprivate let consumer: String
  fileprivate let pactVerificationService: PactVerificationService
  fileprivate var interactions: [Interaction] = []

  open var baseUrl: String {
    return pactVerificationService.baseUrl
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

  open func given(_ providerState: String) -> Interaction {
    let interaction = Interaction().given(providerState)
    interactions.append(interaction)
    return interaction
  }

  @objc(uponReceiving:)
  open func uponReceiving(_ description: String) -> Interaction {
    let interaction = Interaction().uponReceiving(description)
    interactions.append(interaction)
    return interaction
  }

  @objc(run:)
  open func objcRun(_ testFunction: @escaping (_ testComplete: () -> Void) -> Void) {
    self.run(nil, line: nil, timeout: 30, testFunction: testFunction)
  }

  @objc(run: withTimeout:)
  open func objcRun(_ testFunction: @escaping (_ testComplete: () -> Void) -> Void, timeout: TimeInterval) {
    self.run(nil, line: nil, timeout: timeout, testFunction: testFunction)
  }

  open func run(_ file: String? = #file, line: UInt? = #line, timeout: TimeInterval = 30,
                testFunction: @escaping (_ testComplete: @escaping () -> Void) -> Void) {
    var complete = false
    self.pactVerificationService.setup(self.interactions).onSuccess { _ in
      testFunction { () in
        self.pactVerificationService.verify(provider: self.provider, consumer: self.consumer).onSuccess { _ in
          complete = true
        }.onFailure { error in
          if let fileName = file, let lineNumber = line {
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
    if let fileName = file, let lineNumber = line {
      expect(fileName, line: lineNumber, expression: { complete }).toEventually(beTrue())
    } else {
      expect(complete).toEventually(beTrue(), timeout: timeout)
    }
  }
}
