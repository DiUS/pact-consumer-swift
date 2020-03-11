//
//  XCTestErrorReporter.swift
//  
//
//  Created by Ruben Cagnie on 3/9/20.
//

import Foundation
import XCTest

public class XCTestErrorReporter: ErrorReporter {
    weak var test: XCTestCase?

    public init(test: XCTestCase) {
        self.test = test
    }

    public func reportFailure(_ message: String) {
        test?.recordFailure(withDescription: message, inFile: #file, atLine: #line, expected: false)
    }

    public func reportFailure(_ message: String, file: FileString, line: UInt) {
        test?.recordFailure(withDescription: message, inFile: file.description, atLine: Int(line), expected: false)
    }
}
