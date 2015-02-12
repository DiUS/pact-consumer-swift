import Quick
import Nimble
import PactConsumerSwift

class MockServiceSpec: QuickSpec {
  override func spec() {

    describe("init") {

    }

    describe("") {
      var service: MockService?
      beforeEach { service = MockService(provider: "test provider", consumer: "ios client", done: { result in }) }

      describe("interaction state setup") {
        it("it initialises the provider state") {

        }
      }
    }
  }
}
