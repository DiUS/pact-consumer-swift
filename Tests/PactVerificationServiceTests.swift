//
//  PactVerificationServiceTests.swift
//  PactConsumerSwift
//
//  Created by Marko Justinek on 26/9/17.
//

import XCTest
import Alamofire
import BrightFutures

@testable import PactConsumerSwift

class PactVerificationServiceTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
  }
    
  override func tearDown() {
    super.tearDown()
  }

  func test_PactVerificationService_setup_ThrowsError() {
    let sut = PactVerificationService(url: "http://bogusurl.com", port: 4321)
    let expect = expectation(description: "PactVerificationService Should Throw at setup()")
    let interactions = [Interaction]()
    sut.setup(interactions)
      .onSuccess { success in
        debugPrint("SUCCESS: \(success)")
        XCTFail("PactVerificationService should throw when passing invalid interactions")
        expect.fulfill()
      }
      .onFailure { error in
        debugPrint("ERROR: \(error)")
        XCTAssertNotNil(error)
        expect.fulfill()
    }
    
    waitForExpectations(timeout: 10) { error in
      XCTAssertNil(error, "Test timed out. \(String(describing: error?.localizedDescription))")
    }
  }
  
}
