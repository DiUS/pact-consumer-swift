import Quick
import Nimble
import PactConsumerSwift

class HelloClientSpec: QuickSpec {
  override func spec() {
    var helloProvider: MockService?
    var helloClient: HelloClient?

    describe("tests fulfilling all expected interactions") {
      beforeEach {
        helloProvider = MockService(provider: "Hello Provider", consumer: "Hello Consumer Swift", done: { result in
          expect(result).to(equal(PactVerificationResult.Passed))
        })
        helloClient = HelloClient(baseUrl: helloProvider!.baseUrl)
      }

      it("it says Hello") {
        var hello = "not Goodbye"

        helloProvider!.uponReceiving("a request for hello")
                      .withRequest(PactHTTPMethod.Get, path: "/sayHello")
                      .willRespondWith(200, headers: ["Content-Type": "application/json"], body: ["reply": "Hello"])

        //Run the tests
        helloProvider!.run { (testComplete) -> Void in
          helloClient!.sayHello { (response) in
            hello = response
            testComplete()
          }
        }

        expect(hello).toEventually(contain("Hello"))
      }

      describe("findFriendsByAgeAndChildren") {
        it("should return some friends") {
          var friends: Array<String> = []

          helloProvider!.uponReceiving("a request friends")
                        .withRequest(PactHTTPMethod.Get, path: "/friends", query: ["age": "30", "child": "Mary"])
                        .willRespondWith(200, headers: ["Content-Type": "application/json"], body: ["friends": ["Sue"]])

          //Run the tests
          helloProvider!.run { (testComplete) -> Void in
            helloClient!.findFriendsByAgeAndChild {
              (response) in
              friends = response
              testComplete()
            }
          }

          expect(friends).toEventually(contain("Sue"))
        }
      }

      describe("unfriendMe") {
        it("should unfriend me") {
          var responseValue: Dictionary<String, String> = [:]

          helloProvider!.given("I am friends with Fred")
                        .uponReceiving("a request to unfriend")
                        .withRequest(PactHTTPMethod.Put, path: "/unfriendMe")
                        .willRespondWith(200, headers: ["Content-Type": "application/json"], body: ["reply": "Bye"])

          //Run the tests
          helloProvider!.run{ (testComplete) -> Void in
            helloClient!.unfriendMe({ (response) in
              responseValue = response
              testComplete()
            }, errorResponse: { (error) in
              expect(true).to(equal(false))
              testComplete()
            })
          }

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
          helloProvider!.run { (testComplete) -> Void in
            helloClient!.unfriendMe({ (response) in
              expect(true).to(equal(false))
              testComplete()
            }, errorResponse: { (error) in
              errorCode = error
              testComplete()
            })
          }

          expect(errorCode).toEventually(equal(404))
        }
      }

      describe("multiple interactions") {
        it("should allow multiple interactions in test setup") {
          var friends: Array<Dictionary<String, String>> = []

          helloProvider!.given("'s got no friends")
                        .uponReceiving("a friend request")
                        .withRequest(PactHTTPMethod.Post, path: "/friends", body: ["id": "12341"])
                        .willRespondWith(200, headers: ["Content-Type": "application/json"])
          helloProvider!.uponReceiving("request's friends")
                        .withRequest(PactHTTPMethod.Get, path: "/friends")
                        .willRespondWith(200, headers: ["Content-Type": "application/json"], body: ["friends": [["id": "12341"]]])

          //Run the tests
          helloProvider!.run { (testComplete) -> Void in
            helloClient!.requestFriend("12341") { () in
              helloClient!.findFriends { (response) in
                friends = response
                testComplete()
              }
            }
          }

          expect(friends).toEventually(contain(["id": "12341"]))
        }
      }
    }

    describe("when not all expected interactions are not fulfilled") {
      it("it fails tests when verification fails") {
        var verificationResult = PactVerificationResult.Passed
        var helloProvider = MockService(provider: "Hello Provider", consumer: "Hello Consumer", done: {
          result in
          // expected interactions not performed
          verificationResult = result
        })

        helloProvider.uponReceiving("a request for hello")
                      .withRequest(PactHTTPMethod.Get, path: "/sayHello")
                      .willRespondWith(200, headers: ["Content-Type": "application/json"], body: [ "reply": "Hello"])

        helloProvider.run { (testComplete) -> Void in
          testComplete()
        }

        expect(verificationResult).toEventually(equal(PactVerificationResult.Failed))
      }
    }
  }
}
