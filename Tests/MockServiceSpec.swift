import Quick
import Nimble
@testable import PactConsumerSwift

class MockServiceSpec: QuickSpec {
  override func spec() {
    var pactServicePactStub: RubyPactMockServiceStub?
    var mockService: MockService?
    var errorCapturer: ErrorCapture?

    beforeEach {
      pactServicePactStub = RubyPactMockServiceStub()
      errorCapturer = ErrorCapture()
      mockService = MockService(provider: "ABC Service",
                                consumer: "unit tests",
                                pactVerificationService: PactVerificationService(),
                                errorReporter: errorCapturer!)

      mockService!
        .uponReceiving("test request")
        .withRequest(method: .GET,
                     path: "/widgets")
        .willRespondWith(status: 200,
                         headers: ["Content-Type": "application/json"],
                         body: ["name": "test response"])
    }

    afterEach {
      pactServicePactStub!.reset()
    }

    describe("pact verification succeeds") {
      beforeEach {
        pactServicePactStub!
          .clean(responseCode: 200, response: "Cleaned OK")
          .setupInteractions(responseCode: 200, response: "Setup succeeded")
          .verifyInteractions(responseCode: 200, response: "Verify succeeded")
          .writePact(responseCode: 200, response: "Writing pact succeeded")
      }

      it("creates expected interactions in mock service") {
        mockService!.run() { (testComplete) -> Void in
          testComplete()
        }
        expect(pactServicePactStub!.setupInteractionsStub.requestExecuted).to(equal(true))
        expect(pactServicePactStub!.setupInteractionsStub.requestBody).to(contain(
          "\"description\":\"test request\""
        ))
      }

      it("calls test function") {
        var calledTestFunction = false
        mockService!.run() { (testComplete) -> Void in
          calledTestFunction = true
          testComplete()
        }
        expect(calledTestFunction).to(equal(true))
      }

      it("writes pact for provider / consumer combination") {
        mockService!.run() { (testComplete) -> Void in
          testComplete()
        }
        expect(pactServicePactStub!.writePactStub.requestExecuted).to(equal(true))
        expect(pactServicePactStub!.writePactStub.requestBody).to(contain(
          "\"provider\":{\"name\":\"ABC Service\""
        ))
        expect(pactServicePactStub!.writePactStub.requestBody).to(contain(
          "\"consumer\":{\"name\":\"unit tests\""
        ))
      }
    }

    context("when cleaning previous interactions fails") {
      beforeEach {
        pactServicePactStub!.clean(responseCode: 500, response: "Error cleaning interactions")
      }

      it("does not call test function") {
        var calledTestFunction = false
        mockService!.run() { (testComplete) -> Void in
          calledTestFunction = true
          testComplete()
        }
        expect(calledTestFunction).to(equal(false))
      }

      it("returns error message from mock service") {
        mockService!.run() { (testComplete) -> Void in
          testComplete()
        }
        expect(errorCapturer!.message!.message).to(contain("Error setting up pact: Error cleaning interactions"))
      }

      it("does not attempt to setup interactions or write pact") {
        mockService!.run() { (testComplete) -> Void in
          testComplete()
        }
        expect(pactServicePactStub!.cleanStub.requestExecuted).to(equal(true))
        expect(pactServicePactStub!.setupInteractionsStub.requestExecuted).to(equal(false))
        expect(pactServicePactStub!.verifyInteractionsStub.requestExecuted).to(equal(false))
        expect(pactServicePactStub!.writePactStub.requestExecuted).to(equal(false))
      }
    }

    describe("pact setup fails") {
      beforeEach {
        pactServicePactStub!
          .clean(responseCode: 200, response: "Cleaned OK")
          .setupInteractions(responseCode: 500, response: "Error setting up interactions")
      }

      it("does not call test function") {
        var calledTestFunction = false
        mockService!.run() { (testComplete) -> Void in
          calledTestFunction = true
          testComplete()
        }
        expect(calledTestFunction).to(equal(false))
      }

      it("returns error message from mock service") {
        mockService!.run() { (testComplete) -> Void in
          testComplete()
        }
        expect(errorCapturer!.message!.message).to(contain("Error setting up pact: Error setting up interactions"))
      }

      it("does not attempt to verify or write pact") {
        mockService!.run() { (testComplete) -> Void in
          testComplete()
        }
        expect(pactServicePactStub!.cleanStub.requestExecuted).to(equal(true))
        expect(pactServicePactStub!.setupInteractionsStub.requestExecuted).to(equal(true))
        expect(pactServicePactStub!.verifyInteractionsStub.requestExecuted).to(equal(false))
        expect(pactServicePactStub!.writePactStub.requestExecuted).to(equal(false))
      }
    }

    describe("pact verification fails") {
      beforeEach {
        pactServicePactStub!
          .clean(responseCode: 200, response: "Cleaned OK")
          .setupInteractions(responseCode: 200, response: "Setup succeeded")
          .verifyInteractions(responseCode: 500, response: "Error running verification")
      }

      it("calls test function") {
        var calledTestFunction = false
        mockService!.run() { (testComplete) -> Void in
          calledTestFunction = true
          testComplete()
        }
        expect(calledTestFunction).to(equal(true))
      }

      it("returns error message from mock service") {
        mockService!.run() { (testComplete) -> Void in
          testComplete()
        }
        expect(errorCapturer!.message!.message).to(contain(
          "Verification error (check build log for mismatches): Error running verification"
        ))
      }

      it("does not attempt to write pact") {
        mockService!.run() { (testComplete) -> Void in
          testComplete()
        }
        expect(pactServicePactStub!.cleanStub.requestExecuted).to(equal(true))
        expect(pactServicePactStub!.setupInteractionsStub.requestExecuted).to(equal(true))
        expect(pactServicePactStub!.verifyInteractionsStub.requestExecuted).to(equal(true))
        expect(pactServicePactStub!.writePactStub.requestExecuted).to(equal(false))
      }
    }

    describe("writing pact fails") {
      beforeEach {
        pactServicePactStub!
          .clean(responseCode: 200, response: "Cleaned OK")
          .setupInteractions(responseCode: 200, response: "Setup succeeded")
          .verifyInteractions(responseCode: 200, response: "Verify succeeded")
          .writePact(responseCode: 500, response: "Error writing pact")
      }

      it("calls test function") {
        var calledTestFunction = false
        mockService!.run() { (testComplete) -> Void in
          calledTestFunction = true
          testComplete()
        }
        expect(calledTestFunction).to(equal(true))
      }

      it("returns error message from mock service") {
        mockService!.run() { (testComplete) -> Void in
          testComplete()
        }
        expect(errorCapturer!.message!.message).to(contain(
          "Verification error (check build log for mismatches): Error writing pact"
        ))
      }

      it("executes all expected requests") {
        mockService!.run() { (testComplete) -> Void in
          testComplete()
        }
        expect(pactServicePactStub!.cleanStub.requestExecuted).to(equal(true))
        expect(pactServicePactStub!.setupInteractionsStub.requestExecuted).to(equal(true))
        expect(pactServicePactStub!.verifyInteractionsStub.requestExecuted).to(equal(true))
        expect(pactServicePactStub!.writePactStub.requestExecuted).to(equal(true))
      }
    }

    describe("when test function throws error") {
      beforeEach {
        pactServicePactStub!
          .clean(responseCode: 200, response: "Cleaned OK")
          .setupInteractions(responseCode: 200, response: "Setup succeeded")
      }

      enum MockError: Error {
        case problem
      }

      it("returns message from thrown error") {
        mockService!.run() { _ -> Void in
          throw MockError.problem
        }
        expect(errorCapturer!.message!.message).to(contain(
          "Error thrown in test function (check build log):"
        ))
      }
    }
  }
}
