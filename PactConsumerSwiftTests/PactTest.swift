import Quick
import Nimble
import PactConsumerSwift
import Alamofire

class HelloClientSpec: QuickSpec {
  override func spec() {
    it("it says Hello") {
      var hello = "not Goodbye"
      var helloProvider = MockService(provider: "Hello Provider", consumer: "Hello Consumer")

      helloProvider.uponReceiving("a request for hello")
                   .withRequest(.GET, path: "/sayHello")
                   .willRespondWith(200, headers: ["Content-Type": "application/json"], body: [ "reply": "Hello"])

      //Run the tests
      helloProvider.run ( { (complete) -> Void in
        HelloClient(baseUrl: helloProvider.baseUrl).sayHello { (response) in
          hello = response
          complete()
        }
      }, result: { (verification) -> Void in
        expect(verification).to(equal(VerificationResult.PASSED))
      })
      

      expect(hello).toEventually(contain("Hello"))
    }

    it("it fails tests when verification fails") {
      var verificationResult = VerificationResult.PASSED
      var helloProvider = MockService(provider: "Hello Provider", consumer: "Hello Consumer")
      
      helloProvider.uponReceiving("a request for hello")
        .withRequest(.GET, path: "/sayHello")
        .willRespondWith(200, headers: ["Content-Type": "application/json"], body: [ "reply": "Hello"])
      
      //Run the tests
      helloProvider.run ( { (complete) -> Void in
        // TODO: Should not need to have any code in here other than complete()!
        HelloClient(baseUrl: helloProvider.baseUrl)
        complete()
      }, result: { (verification) -> Void in
        verificationResult = verification
      })

      expect(verificationResult).toEventually(equal(VerificationResult.FAILED))
    }
  }
}
