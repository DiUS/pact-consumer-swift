import Foundation

public typealias FileString = StaticString

public protocol ErrorReporter {
  func reportFailure(_ message: String)
  func reportFailure(_ message: String, file: FileString, line: UInt)
}
