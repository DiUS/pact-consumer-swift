import Foundation
import Nimble

class XCodeErrorReporter: ErrorReporter {
  func reportFailure(_ message: String) {
    fail(message)
  }
  func reportFailure(_ message: String, file: String, line: UInt) {
    fail(message, file: file, line: line)
  }
}
