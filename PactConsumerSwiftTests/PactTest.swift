import Quick
import Nimble
import PactConsumerSwift
import Alamofire

class HelloClientSpec: QuickSpec {
  override func spec() {
    it("is friendly") {
      var hello = "nothingHere"

      var helloProvider = MockService(provider: "Hello Provider", consumer: "Hello Consumer")

      helloProvider.uponReceiving("a request for hello")
                   .withRequest(.GET, path: "/sayHello")
                   .willRespondWith(200, headers: ["Content-Type": "application/json"], body: [ "reply": "Hello"])

      //Run the tests
      helloProvider.run { (complete) in
        HelloClient(baseUrl: helloProvider.baseUrl).sayHello { (response) in
          hello = response
        }
        complete()
      }

      expect(hello).toEventually(contain("Hello"))
    }
  }
}
