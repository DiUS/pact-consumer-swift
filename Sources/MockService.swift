import Foundation
import BrightFutures
import Nimble

@objc
open class MockService: NSObject {
  private let pact: Pact
  private let mockServer: MockServer
  private var interactions: [Interaction] = []
  private let errorReporter: ErrorReporter

  /// The baseUrl of Pact Mock Service
  @objc
  open var baseUrl: String {
    return mockServer.getBaseUrl()
  }

  public convenience init(provider: String,
                          consumer: String,
                          mockServer: MockServer,
                          errorReporter: ErrorReporter) {
        self.init(provider: provider,
                  consumer: consumer,
                  mockServer: mockServer,
                  matchers: RubyMatcher(),
                  errorReporter: errorReporter)
  }

    ///
    /// Initializer
    ///
    /// - parameter provider: Name of your provider (eg: Calculator API)
    /// - parameter consumer: Name of your consumer (eg: Calculator.app)
    /// - parameter mockServer: Your customised `MockServer` implementation
    /// - parameter errorReporter: Your customised `ErrorReporter`
    ///
  public init(provider: String,
              consumer: String,
              mockServer: MockServer,
              matchers: Matchers,
              errorReporter: ErrorReporter) {
    self.pact = Pact(provider: provider, consumer: consumer)
    self.mockServer = mockServer
    Matcher.matchers = matchers
    self.errorReporter = errorReporter
  }

    ///
    /// Convenience Initializer
    ///
    /// - parameter provider: Name of your provider (eg: Calculator API)
    /// - parameter consumer: Name of your consumer (eg: Calculator.app)
    ///
    /// Use this initialiser to use the default XCodeErrorReporter
    ///

  @objc(initWithProvider: consumer:)
  public convenience init(provider: String,
                          consumer: String) {
    self.init(provider: provider,
              consumer: consumer,
              mockServer: PactVerificationService(),
              matchers: RubyMatcher(),
              errorReporter: XCodeErrorReporter())
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
  open func run(_ file: FileString? = #file, line: UInt? = #line, timeout: TimeInterval = 30,
                testFunction: @escaping (_ testComplete: @escaping () -> Void) -> Void) {
    waitUntilWithLocation(timeout: timeout, file: file, line: line) { done in
      self.pact.withInteractions(self.interactions)
      self.mockServer.setup(self.pact).onSuccess { _ in
        testFunction { () in
          done()
        }
      }.onFailure { error in
        self.failWithLocation("Error setting up pact: \(error.localizedDescription)", file: file, line: line)
        done()
      }
    }
    waitUntilWithLocation(timeout: timeout, file: file, line: line) { done in
        self.mockServer.verify(self.pact).onSuccess { _ in
            done()
        }.onFailure { error in
          self.failWithLocation("Verification error (check build log for mismatches): \(error.localizedDescription)",
          file: file,
          line: line)
          print("warning: Make sure the testComplete() fuction is called at the end of your test.")
          done()
        }
    }
  }

    // MARK: - Helper methods
    private func failWithLocation(
      _ message: String,
      file: FileString?,
      line: UInt?
    ) {
      if let fileName = file, let lineNumber = line {
        self.errorReporter.reportFailure(message, file: fileName, line: lineNumber)
      } else {
        self.errorReporter.reportFailure(message)
      }
    }

    // merge-todo this might be up for deletion
  func failWithError(_ error: PactError, file: FileString?, line: UInt?) {
    switch error {
    case let .setupError(message):
      self.failWithLocation("Error setting up pact: \(message)",
        file: file,
        line: line)
    case let .executionError(message):
      self.failWithLocation("Error executing pact: \(message)",
        file: file,
        line: line)
    case let .missmatches(message):
      self.failWithLocation("Error verifying pact. Missmatches: \(message)",
        file: file,
        line: line)
    case .writeError(let message):
      self.failWithLocation("Error writing pact: \(message)",
        file: file,
        line: line)
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
