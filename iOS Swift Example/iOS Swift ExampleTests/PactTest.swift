import Quick
import Nimble
import PactConsumerSwift
import iOS_Swift_Example

class HelloClientSpec: QuickSpec {
  override func spec() {
    it("it says Hello") {
      var hello = "not Goodbye"
      var helloProvider = MockService(provider: "Hello Provider", consumer: "Hello Consumer")

      helloProvider.uponReceiving("a request for hello")
                   .withRequest(PactHTTPMethod.Get, path: "/sayHello")
                   .willRespondWith(200, headers: ["Content-Type": "application/json"], body: [ "reply": "Hello"])

      //Run the tests
      helloProvider.run ( { (complete) -> Void in
        HelloClient(baseUrl: helloProvider.baseUrl).sayHello { (response) in
          hello = response
          complete()
        }
      }, result: { (verification) -> Void in
        // Important! This ensures all expected HTTP requests were actually made.
        expect(verification).to(equal(PactVerificationResult.Passed))
      })

      expect(hello).toEventually(contain("Hello"))
    }

    it("it fails tests when verification fails") {
      var verificationResult = PactVerificationResult.Passed
      var helloProvider = MockService(provider: "Hello Provider", consumer: "Hello Consumer")
      
      helloProvider.uponReceiving("a request for hello")
        .withRequest(PactHTTPMethod.Get, path: "/sayHello")
        .willRespondWith(200, headers: ["Content-Type": "application/json"], body: [ "reply": "Hello"])
      
      //Run the tests
      helloProvider.run ( { (complete) -> Void in
        complete()
      }, result: { (verification) -> Void in
        verificationResult = verification
      })

      expect(verificationResult).toEventually(equal(PactVerificationResult.Failed))
    }

    describe("findFriendsByAgeAndChildren") {
      it("should return some friends") {
        var friends: Array<String> = []
        var helloProvider = MockService(provider: "Hello Provider", consumer: "Hello Consumer")

        helloProvider.uponReceiving("a request friends")
        .withRequest(PactHTTPMethod.Get, path: "/friends", query: [ "age" : "30", "child" : "Mary" ])
        .willRespondWith(200, headers: ["Content-Type": "application/json"], body: [ "friends": ["Sue"] ])

        //Run the tests
        helloProvider.run({
          (complete) -> Void in
          HelloClient(baseUrl: helloProvider.baseUrl).findFriendsByAgeAndChild {
            (response) in
            friends = response
            complete()
          }
        }, result: {
          (verification) -> Void in
          // Important! This ensures all expected HTTP requests were actually made.
          expect(verification).to(equal(PactVerificationResult.Passed))
        })

        expect(friends).toEventually(contain("Sue"))
      }
    }
  }
}
