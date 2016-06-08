import Quick
import Nimble
import PactConsumerSwift

class PactSwiftSpec: QuickSpec {
  override func spec() {
    var animalMockService: MockService?
    var animalServiceClient: AnimalServiceClient?

    describe("tests fulfilling all expected interactions") {
      beforeEach {
        animalMockService = MockService(provider: "Animal Service", consumer: "Animal Consumer Swift", done: { result in
          expect(result).to(equal(PactVerificationResult.Passed))
        })
        animalServiceClient = AnimalServiceClient(baseUrl: animalMockService!.baseUrl)
      }

      it("gets an alligator") {
        var complete: Bool = false

        animalMockService!.given("an alligator exists")
                          .uponReceiving("a request for an alligator")
                          .withRequest(method:.GET, path: "/alligator")
                          .willRespondWith(status: 200,
                                           headers: ["Content-Type": "application/json"],
                                           body: ["name": "Mary", "type": "alligator"])

        //Run the tests
        animalMockService!.run { (testComplete) -> Void in
          animalServiceClient!.getAlligator( { (alligator) in
              expect(alligator.name).to(equal("Mary"))
              complete = true
              testComplete()
            }, failure: { (error) in
              complete = true
              testComplete()
          })
        }

        // Wait for asynch HTTP requests to finish
        expect(complete).toEventually(beTrue())
      }

      describe("With query params") {
        it("should return animals living in water") {
          var complete: Bool = false

          animalMockService!.given("an alligator exists")
                            .uponReceiving("a request for animals living in water")
                            .withRequest(method:.GET, path: "/animals", query: ["live": "water"])
                            .willRespondWith(status: 200,
                                             headers: ["Content-Type": "application/json"],
                                             body: [ ["name": "Mary", "type": "alligator"] ] )

          //Run the tests
          animalMockService!.run { (testComplete) -> Void in
            animalServiceClient!.findAnimals(live: "water", response: {
              (response) in
              expect(response.count).to(equal(1))
              let name = response[0].name
              expect(name).to(equal("Mary"))
              complete = true
              testComplete()
            })
          }

          // Wait for asynch HTTP requests to finish
          expect(complete).toEventually(beTrue())
        }
      }

      describe("PATCH request") {
        it("should unfriend me") {
          var complete: Bool = false

          animalMockService!.given("Alligators and pidgeons exist")
                        .uponReceiving("a request eat a pidgeon")
                        .withRequest(method:.PATCH, path: "/alligator/eat", body: [ "type": "pidgeon" ])
                        .willRespondWith(status: 204, headers: ["Content-Type": "application/json"])

          //Run the tests
          animalMockService!.run{ (testComplete) -> Void in
            animalServiceClient!.eat(animal: "pidgeon", success: { () in
              complete = true
              testComplete()
            }, error: { (error) in
              expect(true).to(equal(false))
              testComplete()
            })
          }

          expect(complete).toEventually(beTrue())
        }
      }


      describe("Expecting an error response") {
        it("returns an error") {
          var complete: Bool = false

          animalMockService!.given("Alligators don't eat pidgeons")
                        .uponReceiving("a request to no longer eat pidgeons")
                        .withRequest(method:.DELETE, path: "/alligator/eat", body: [ "type": "pidgeon" ])
                        .willRespondWith(status:404, body: "No relationship")

          //Run the tests
          animalMockService!.run { (testComplete) -> Void in
            animalServiceClient!.wontEat(animal: "pidgeon", success: { (response) in
              // We are expecting this test to fail - the error handler should be called
              expect(true).to(equal(false))
              testComplete()
            }, error: { (error) in
              complete = true
              testComplete()
            })
          }

          expect(complete).toEventually(beTrue())
        }
      }

      describe("multiple interactions") {
        it("should allow multiple interactions in test setup") {
          var complete: Bool = false

          animalMockService!.given("alligators don't each pidgeons")
                        .uponReceiving("a request to eat")
                        .withRequest(method:.PATCH, path: "/alligator/eat", body: ["type": "pidgeon"])
                        .willRespondWith(status: 204, headers: ["Content-Type": "application/json"])
          animalMockService!.uponReceiving("what alligators eat")
                        .withRequest(method:.GET, path: "/alligator/eat")
                        .willRespondWith(status:200, headers: ["Content-Type": "application/json"], body: [ ["name": "Joseph", "type": Matcher.somethingLike("pidgeon")]])

          //Run the tests
          animalMockService!.run { (testComplete) -> Void in
            animalServiceClient!.eat(animal: "pidgeon", success: { () in
              animalServiceClient!.eats { (response) in
                expect(response.count).to(equal(1))
                let name = response[0].name
                let type = response[0].type
                expect(name).to(equal("Joseph"))
                expect(type).to(equal("pidgeon"))
                complete = true
                testComplete()
              }
            }, error: { (error) in
              expect(true).to(equal(false))
              testComplete()
            })
          }

          expect(complete).toEventually(beTrue())
        }
      }
      
      describe("Matchers") {
        it("Can match date based on regex") {
          var complete: Bool = false
          
          animalMockService!.given("an alligator exists with a birthdate")
            .uponReceiving("a request for alligator with birthdate")
            .withRequest(method:.GET, path: "/alligator")
            .willRespondWith(
              status: 200,
              headers: ["Content-Type": "application/json"],
              body: [
                "name": "Mary",
                "type": "alligator",
                "dateOfBirth": Matcher.term(
                    matcher: "\\d{2}\\/\\d{2}\\/\\d{4}", 
                    generate: "02/02/1999"
                  )
              ])
          
          //Run the tests
          animalMockService!.run { (testComplete) -> Void in
            animalServiceClient!.getAlligator({ (alligator) in
                expect(alligator.name).to(equal("Mary"))
                expect(alligator.dob).to(equal("02/02/1999"))
                complete = true
                testComplete()
              }, failure: { (error) in
                expect(true).to(equal(false))
                testComplete()
            })
          }
          
          expect(complete).toEventually(beTrue())
        }

        it("Can match legs based on type") {
          var complete: Bool = false
          
          animalMockService!.given("an alligator exists with legs")
            .uponReceiving("a request for alligator with legs")
            .withRequest(method:.GET, path: "/alligator")
            .willRespondWith(
              status: 200,
              headers: ["Content-Type": "application/json"],
              body: [
                "name": "Mary",
                "type": "alligator",
                "legs": Matcher.somethingLike(4)
              ])
          
          //Run the tests
          animalMockService!.run { (testComplete) -> Void in
            animalServiceClient!.getAlligator({ (alligator) in
                expect(alligator.legs).to(equal(4))
                complete = true
                testComplete()
              }, failure: { (error) in
                expect(true).to(equal(false))
                testComplete()
            })
          }
          
          expect(complete).toEventually(beTrue())
        }

        it("Can match based on flexible length array") {
          var complete: Bool = false
          
          animalMockService!.given("multiple land based animals exist")
                            .uponReceiving("a request for animals living on land")
                            .withRequest(
                              method:.GET, 
                              path: "/animals", 
                              query: ["live": "land"])
                            .willRespondWith(
                              status: 200,
                              headers: ["Content-Type": "application/json"],
                              body: Matcher.eachLike(["name": "Bruce", "type": "wombat"]))

          //Run the tests
          animalMockService!.run { (testComplete) -> Void in
            animalServiceClient!.findAnimals(live: "land", response: {
              (response) in
              expect(response.count).to(equal(1))
              expect(response[0].name).to(equal("Bruce"))
              complete = true
              testComplete()
            })
          }

          // Wait for asynch HTTP requests to finish
          expect(complete).toEventually(beTrue())
        }
      }
    }

    describe("when not all expected interactions are not fulfilled") {
      it("it fails tests when verification fails") {
        var verificationResult = PactVerificationResult.Passed
        let animalMockService = MockService(provider: "Animal Service", consumer: "Animal Consumer Swift", done: { result in
          // expected interactions not performed
          verificationResult = result
        })

        animalMockService.uponReceiving("a request for hello")
                      .withRequest(method:.GET, path: "/alligator")
                      .willRespondWith(status:200, headers: ["Content-Type": "application/json"], body: [ "name": "Mary"])

        animalMockService.run { (testComplete) -> Void in
          testComplete()
        }

        expect(verificationResult).toEventually(equal(PactVerificationResult.Failed))
      }
    }
  }
}
