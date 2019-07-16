public protocol ErrorReporter {
  func reportFailure(_ message: String)
  func reportFailure(_ message: String, file: String, line: UInt)
}
