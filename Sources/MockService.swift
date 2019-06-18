import Foundation
import BrightFutures
import Result
import Nimble

@objc
open class MockService: NSObject {
  fileprivate let provider: String
  fileprivate let consumer: String
  fileprivate let pactVerificationService: PactVerificationService
  fileprivate var interactions: [Interaction] = []

  /// The baseUrl of Pact Mock Service
  @objc
  open var baseUrl: String {
    return pactVerificationService.baseUrl
  }

  ///
  /// Initializer
  ///
  /// - parameter provider: Name of your provider (eg: Calculator API)
  /// - parameter consumer: Name of your consumer (eg: Calculator.app)
  /// - parameter pactVerificationService: Your customised `PactVerificationService`
  ///
  public init(
    provider: String,
    consumer: String,
    pactVerificationService: PactVerificationService
    ) {
    self.provider = provider
    self.consumer = consumer
    self.pactVerificationService = pactVerificationService
  }

  ///
  /// Convenience Initializer
  ///
  /// - parameter provider: Name of your provider (eg: Calculator API)
  /// - parameter consumer: Name of your consumer (eg: Calculator.app)
  ///
  /// Use this initialiser to use the default PactVerificationService
  ///
  @objc(initWithProvider: consumer:)
  public convenience init(provider: String, consumer: String) {
    self.init(provider: provider,
              consumer: consumer,
              pactVerificationService: PactVerificationService())
  }

  ///
  /// Define the providers state
  ///
  /// Use this method in the `Arrange` step of your Pact test.
  ///
  ///     myMockService.given("a user exists")
  ///
  /// - Parameter providerState: A description of providers state
  /// - Returns: An `Interaction` object
  ///
  @objc
  open func given(_ providerState: String) -> Interaction {
    let interaction = Interaction().given(providerState)
    interactions.append(interaction)
    return interaction
  }

  ///
  /// Describe the request your provider will receive
  ///
  /// This is the entry point if not using a provider state i.e.:
  ///
  ///     myMockService.uponReceiving("a request for users")
  ///
  /// - Parameter description: Describing the request to the provider
  /// - Returns: An `Interaction` object
  ///
  @objc(uponReceiving:)
  open func uponReceiving(_ description: String) -> Interaction {
    let interaction = Interaction().uponReceiving(description)
    interactions.append(interaction)
    return interaction
  }

  ///
  /// Runs the provided test function with 30 second timeout
  ///
  /// Use this method in the `Act` step of your Pact test.
  /// (eg. Testing your `serviceClientUnderTest!.getUsers(...)` method)
  ///
  ///     [self.mockService run:^(CompleteBlock testComplete) {
  ///       [self. serviceClientUnderTest getUsers]
  ///       testComplete();
  ///     }];
  ///
  /// Make sure you call `testComplete()` after your `Assert` step in your test
  ///
  /// - Parameter testFunction: The function making the network request you are testing
  ///
  @objc(run:)
  open func objcRun(_ testFunction: @escaping (_ testComplete: () -> Void) -> Void) {
    self.run(nil, line: nil, timeout: 30, testFunction: testFunction)
  }

  ///
  /// Runs the provided test function by specifying timeout in seconds
  ///
  /// Use this method in the `Act` step of your Pact test.
  /// (eg. Testing your `serviceClientUnderTest!.getUsers(...)` method)
  ///
  ///     [self.mockService run:^(CompleteBlock testComplete) {
  ///       [self. serviceClientUnderTest getUsers]
  ///       testComplete();
  ///     } withTimeout: 10];
  ///
  /// Make sure you call `testComplete()` after your `Assert` step in your test
  ///
  /// - Parameter testFunction: The function making the network request you are testing
  /// - Parameter timeout: Time to wait for the `testComplete()` else it fails the test
  ///
  @objc(run: withTimeout:)
  open func objcRun(_ testFunction: @escaping (_ testComplete: () -> Void) -> Void,
                    timeout: TimeInterval) {
    self.run(nil, line: nil, timeout: timeout, testFunction: testFunction)
  }

  ///
  /// Runs the provided test function
  ///
  /// Use this method in the `Act` step of your Pact test.
  /// (eg. Testing your `serviceClientUnderTest!.getUsers(...)` method)
  ///
  ///     myMockService!.run(timeout: 10) { (testComplete) -> Void in
  ///         serviceClientUnderTest!.getUsers( /* ... */ )
  ///     }
  ///
  /// Make sure you call `testComplete()` after your `Assert` step in your test
  ///
  /// - Parameter timeout: Number of seconds how long to wait for `testComplete()` before marking the test as failed.
  /// - Parameter testFunction: The function making the network request you are testing
  ///
  open func run(
    _ file: FileString? = #file,
    line: UInt? = #line,
    timeout: TimeInterval = 30,
    testFunction: @escaping (_ testComplete: @escaping () -> Void) -> Void
  ) {
    waitUntilWithLocation(timeout: timeout, file: file, line: line) { done in
      self.pactVerificationService.setup(self.interactions).onSuccess { _ in
        testFunction { () in
          done()
        }
        }.onFailure { error in
          fail("Error setting up pact: \(error.localizedDescription)")
      }
    }

    waitUntilWithLocation(timeout: timeout, file: file, line: line) { done in
      self.pactVerificationService.verify(provider: self.provider,
                                          consumer: self.consumer).onSuccess { _ in
                                            done()
        }.onFailure { error in
          self.failWithLocation("Verification error (check build log for mismatches): \(error.localizedDescription)",
            file: file,
            line: line)
      }
    }
  }

  // MARK: - Helper methods

  func failWithLocation(
    _ message: String,
    file: FileString?,
    line: UInt?
  ) {
    if let fileName = file, let lineNumber = line {
      fail(message, file: fileName, line: lineNumber)
    } else {
      fail(message)
    }
  }

  public func waitUntilWithLocation(
    timeout: TimeInterval,
    file: FileString?,
    line: UInt?,
    action: @escaping (@escaping () -> Void) -> Void
  ) {
    if let fileName = file, let lineNumber = line {
      return waitUntil(timeout: timeout, file: fileName, line: lineNumber, action: action)
    } else {
      return waitUntil(timeout: timeout, action: action)
    }
  }
}
