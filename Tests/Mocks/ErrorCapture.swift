import PactConsumerSwift

struct ErrorReceived {
  var message: String
  var file: String?
  var line: UInt?
}

class ErrorCapture: ErrorReporter {
  public var message: ErrorReceived?

  func reportFailure(_ message: String) {
    self.message = ErrorReceived(message: message, file: nil, line: nil)
  }
  func reportFailure(_ message: String, file: String, line: UInt) {
    self.message = ErrorReceived(message: message, file: file, line: line)
  }

  func clear() {
    self.message = nil
  }
}
