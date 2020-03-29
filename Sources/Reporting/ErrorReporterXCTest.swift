import Foundation
import XCTest

public class ErrorReporterXCTest: ErrorReporter {
    
    public func reportFailure(_ message: String) {
        XCTFail(message, file: #file, line: #line)
    }

    public func reportFailure(_ message: String, file: FileString, line: UInt) {
        XCTFail(message, file: file, line: line)
    }

}
