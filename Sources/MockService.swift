import Foundation
import XCTest

@objc
open class MockService: NSObject {
  private let provider: String
  private let consumer: String
  private let pactVerificationService: PactVerificationService
  private var interactions: [Interaction] = []
  private let errorReporter: ErrorReporter

  /// The baseUrl of Pact Mock Service
  @objc
  public var baseUrl: String {
    return pactVerificationService.baseUrl
  }

  ///
  /// Initializer
  ///
  /// - parameter provider: Name of your provider (eg: Calculator API)
  /// - parameter consumer: Name of your consumer (eg: Calculator.app)
  /// - parameter pactVerificationService: Your customised `PactVerificationService`
  /// - parameter errorReporter: Your customised `ErrorReporter`
  ///
  public init(
    provider: String,
    consumer: String,
    pactVerificationService: PactVerificationService,
    errorReporter: ErrorReporter
  ) {
    self.provider = provider
    self.consumer = consumer
    self.pactVerificationService = pactVerificationService
    self.errorReporter = errorReporter
  }

  ///
  /// Convenience Initializer
  ///
  /// - parameter provider: Name of your provider (eg: Calculator API)
  /// - parameter consumer: Name of your consumer (eg: Calculator.app)
  /// - parameter pactVerificationService: Your customised `PactVerificationService`
  ///
  /// Use this initialiser to use the default XCodeErrorReporter
  ///
  @objc(initWithProvider: consumer: andVerificationService:)
  public convenience init(provider: String, consumer: String, pactVerificationService: PactVerificationService) {
    self.init(provider: provider,
              consumer: consumer,
              pactVerificationService: pactVerificationService,
              errorReporter: ErrorReporterXCTest())
  }

  ///
  /// Convenience Initializer
  ///
  /// - parameter provider: Name of your provider (eg: Calculator API)
  /// - parameter consumer: Name of your consumer (eg: Calculator.app)
  ///
  /// Use this initialiser to use the default PactVerificationService and ErrorReporter
  ///
  @objc(initWithProvider: consumer:)
  public convenience init(provider: String, consumer: String) {
    self.init(provider: provider,
              consumer: consumer,
              pactVerificationService: PactVerificationService(),
              errorReporter: ErrorReporterXCTest())
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
  public func given(_ providerState: String) -> Interaction {
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
  public func uponReceiving(_ description: String) -> Interaction {
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
  public func objcRun(_ testFunction: @escaping (_ testComplete: @escaping () -> Void) -> Void) {
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
  public func objcRun(
    _ testFunction: @escaping (_ testComplete: @escaping () -> Void) -> Void,
    timeout: TimeInterval
  ) {
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
  public func run(
    _ file: FileString? = #file,
    line: UInt? = #line,
    timeout: TimeInterval = 30,
    testFunction: @escaping (_ testComplete: @escaping () -> Void) throws -> Void
  ) {
    waitUntilWithLocation(timeout: timeout, file: file, line: line) { done in
      self
        .pactVerificationService
        .setup(self.interactions) { result in
          switch result {
          case .success:
            do {
              try testFunction { done() }
            } catch {
              self.failWithLocation(
                "Error thrown in test function (check build log): \(error.localizedDescription)",
                file: file,
                line: line
              )
              done()
            }
          case .failure(let error):
            self.failWithLocation("Error setting up pact: \(error.localizedDescription)", file: file, line: line)
            done()
          }
        }
    }

    waitUntilWithLocation(timeout: timeout, file: file, line: line) { done in
      self
        .pactVerificationService
        .verify(provider: self.provider, consumer: self.consumer) { result in
          switch result {
          case .success:
            done()
          case .failure(let error):
            self.failWithLocation("Verification error (check build log for mismatches): \(error.localizedDescription)",
              file: file,
              line: line)
            done()
          }
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

  private func waitUntilWithLocation(
    timeout: TimeInterval,
    file: FileString?,
    line: UInt?,
    action: @escaping (@escaping () -> Void) -> Void
  ) {
    let expectation = XCTestExpectation(description: "waitUntilWithLocation")
    action { expectation.fulfill() }

    let result = XCTWaiter().wait(for: [expectation], timeout: timeout)
    if result != .completed {
        let message = "test did not complete within \(timeout) second timeout"
        if let fileName = file, let lineNumber = line {
            errorReporter.reportFailure(message, file: fileName, line: lineNumber)
        } else {
            errorReporter.reportFailure(message)
        }
    }
  }
}
