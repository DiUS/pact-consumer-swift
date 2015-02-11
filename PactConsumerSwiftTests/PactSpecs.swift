import Quick
import Nimble
import PactConsumerSwift

class HelloClientSpec: QuickSpec {
  override func spec() {
    var helloProvider : MockService?
    var helloClient : HelloClient?
    
    beforeEach {
      helloProvider = MockService(provider: "Hello Provider", consumer: "Hello Consumer")
      helloClient = HelloClient(baseUrl: helloProvider!.baseUrl)
    }
    
    it("it says Hello") {
      var hello = "not Goodbye"
      
      helloProvider!.uponReceiving("a request for hello")
                    .withRequest(PactHTTPMethod.Get, path: "/sayHello")
                    .willRespondWith(200, headers: ["Content-Type": "application/json"], body: [ "reply": "Hello"])
      
      //Run the tests
      helloProvider!.run ( { (complete) -> Void in
        helloClient!.sayHello { (response) in
          hello = response
          complete()
        }
        }, verification: { (verification) -> Void in
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
        }, verification: { (verification) -> Void in
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
          helloClient!.findFriendsByAgeAndChild {
            (response) in
            friends = response
            complete()
          }
          }, verification: {
            (verification) -> Void in
            // Important! This ensures all expected HTTP requests were actually made.
            expect(verification).to(equal(PactVerificationResult.Passed))
        })
        
        expect(friends).toEventually(contain("Sue"))
      }
    }
    
    describe("unfriendMe") {
      it("should unfriend me") {
        var responseValue: Dictionary<String, String> = [:]
        
        helloProvider!.given("I am friends with Fred")
                      .uponReceiving("a request to unfriend")
                      .withRequest(PactHTTPMethod.Put, path: "/unfriendMe")
                      .willRespondWith(200, headers: ["Content-Type": "application/json"], body: [ "reply": "Bye" ])
        
        //Run the tests
        helloProvider!.run({
          (complete) -> Void in
          helloClient!.unfriendMe( {
            (response) in
            responseValue = response
            complete()
            }, errorResponse: {
              (error) in
              expect(true).to(equal(false))
              complete()
          })
          }, verification: {
            (verification) -> Void in
            // Important! This ensures all expected HTTP requests were actually made.
            expect(verification).to(equal(PactVerificationResult.Passed))
        })
        
        expect(responseValue["reply"]).toEventually(contain("Bye"))
      }
    }
    
    
    describe("when there are no friends") {
      it("returns an error message") {
        var errorCode: Int? = nil
        
        helloProvider!.given("I have no friends")
                      .uponReceiving("a request to unfriend")
                      .withRequest(PactHTTPMethod.Put, path: "/unfriendMe")
                      .willRespondWith(404, body: "No friends")
        
        //Run the tests
        helloProvider!.run({
          (complete) -> Void in
          helloClient!.unfriendMe({
            (response) in
            expect(true).to(equal(false))
            complete()
            }, errorResponse: {
              (error) in
              errorCode = error
              complete()
          })
          }, verification: {
            (verification) -> Void in
            // Important! This ensures all expected HTTP requests were actually made.
            expect(verification).to(equal(PactVerificationResult.Passed))
        })
        
        expect(errorCode).toEventually(equal(404))
      }
    }

    describe("multiple interactions") {
      it("should allow multiple interactions in test setup") {
        var friends: Array<Dictionary<String, String>> = []
        var helloProvider = MockService(provider: "Hello Provider", consumer: "Hello Consumer")

        helloProvider.given("'s got no friends")
                      .uponReceiving("a friend request")
                      .withRequest(PactHTTPMethod.Post, path: "/friends", body: [ "id" : "12341" ])
                      .willRespondWith(200, headers: ["Content-Type": "application/json"])
        helloProvider.uponReceiving("request's friends")
                    .withRequest(PactHTTPMethod.Get, path: "/friends")
                    .willRespondWith(200, headers: ["Content-Type": "application/json"], body: [ "friends": [ ["id" : "12341"] ] ])

        //Run the tests
        helloProvider.run({
          (complete) -> Void in
          helloClient!.requestFriend("12341") {
            () in
            helloClient!.findFriends {
              (response) in
              friends = response
              complete()
            }
          }
        }, verification: {
          (verification) -> Void in
          // Important! This ensures all expected HTTP requests were actually made.
          expect(verification).to(equal(PactVerificationResult.Passed))
        })

        expect(friends).toEventually(contain(["id": "12341"]))
      }
    }
  }
}
