import Foundation
import Alamofire
import BrightFutures
import Result
import Nimble

@objc
open class MockService: NSObject {
  fileprivate let pact: Pact
  fileprivate let mockServer: MockServer
  fileprivate var interactions: [Interaction] = []

  @objc
  open var baseUrl: String {
    return mockServer.getBaseUrl()
  }

  public init(provider: String,
              consumer: String,
              mockServer: MockServer) {
    self.pact = Pact(provider: provider, consumer: consumer)
    self.mockServer = mockServer
  }

  @objc(initWithProvider: consumer:)
  public convenience init(provider: String, consumer: String) {
    self.init(provider: provider,
              consumer: consumer,
              mockServer: RubyMockServer())
  }

  @objc
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
  open func objcRun(_ testFunction: @escaping (_ testComplete: () -> Void) -> Void,
                    timeout: TimeInterval) {
    self.run(nil, line: nil, timeout: timeout, testFunction: testFunction)
  }

  open func run(_ file: FileString? = #file, line: UInt? = #line, timeout: TimeInterval = 30,
                testFunction: @escaping (_ testComplete: @escaping () -> Void) -> Void) {
    waitUntilWithLocation(timeout: timeout, file: file, line: line) { done in
      self.pact.withInteractions(self.interactions)
      self.mockServer.setup(self.pact).onSuccess { _ in
        testFunction { () in
          done()
        }
      }.onFailure { error in
        fail("Error setting up pact: \(error.localizedDescription)")
      }
    }

    self.mockServer.verify(self.pact).onSuccess { _ in
    }.onFailure { error in
      self.failWithLocation("Verification error (check build log for mismatches): \(error.localizedDescription)",
        file: file,
        line: line)
      print("warning: Make sure the testComplete() fuction is called at the end of your test.")
    }
  }

  func failWithLocation(_ message: String, file: FileString?, line: UInt?) {
    if let fileName = file, let lineNumber = line {
      fail(message, file: fileName, line: lineNumber)
    } else {
      fail(message)
    }
  }

  public func waitUntilWithLocation(timeout: TimeInterval,
                                    file: FileString?,
                                    line: UInt?,
                                    action: @escaping (@escaping () -> Void) -> Void) {
    if let fileName = file, let lineNumber = line {
      return waitUntil(timeout: timeout, file: fileName, line: lineNumber, action: action)
    } else {
      return waitUntil(timeout: timeout, action: action)
    }
  }
}
