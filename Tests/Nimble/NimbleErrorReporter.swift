import Foundation
import Nimble
import PactConsumerSwift

class NimbleErrorReporter: ErrorReporter {
  func reportFailure(_ message: String) {
    fail(message)
  }

  func reportFailure(_ message: String, file: FileString, line: UInt) {
    fail(message, file: file, line: line)
  }
}

extension MockService {

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
                errorReporter: NimbleErrorReporter())
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
                errorReporter: NimbleErrorReporter())
    }

}
