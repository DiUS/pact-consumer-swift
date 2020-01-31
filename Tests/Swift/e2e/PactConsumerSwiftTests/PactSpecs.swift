import Quick
import Nimble
@testable import PactConsumerSwift

enum TestSetup {
  case Ruby
  case Rust

  func mockServer() -> MockServer {
    switch self {
    case .Ruby:
      return RubyMockServer()
    case .Rust:
      return NativeMockServerWrapper()
    }
  }

  var name: String {
    switch self {
    case .Ruby:
      return "Ruby Mock Server"
    case .Rust:
      return "Rust Mock Server"
    }
  }

  var matcher: Matchers {
    switch self {
    case .Ruby:
      return RubyMatcher()
    case .Rust:
      return NativeMatcher()
    }
  }
}

class PactSwiftSpec: QuickSpec {
  override func spec() {
    var animalMockService: MockService?
    var animalServiceClient: AnimalServiceClient?

    let allMockServers = [TestSetup.Ruby, TestSetup.Rust]
    allMockServers.forEach { (testSetup) in
      describe("Test against \(testSetup.name)") {
        describe("tests fulfilling all expected interactions") {
          beforeEach {
            animalMockService = MockService(provider: "Animal Service", consumer: "Animal Consumer Swift", mockServer: testSetup.mockServer(), matchers: testSetup.matcher)
            animalServiceClient = AnimalServiceClient(baseUrl: animalMockService!.baseUrl)
          }

          it("gets an alligator") {
            animalMockService!.given("an alligator exists")
              .uponReceiving("a request for all alligators")
              .withRequest(method:.GET, path: "/alligators")
              .willRespondWith(status: 200,
                              headers: ["Content-Type": "application/json"],
                              body: [ ["name": "Mary", "type": "alligator"] ])

            //Run the tests
            animalMockService!.run { (testComplete) -> Void in
              animalServiceClient!.getAlligators( { (alligators) in
                expect(alligators[0].name).to(equal("Mary"))
                testComplete()
              }, failure: { (error) in
                testComplete()
              })
            }
          }

          it("gets an alligator with path matcher") {
            let pathMatcher = testSetup.matcher.term(matcher: "^\\/alligators\\/[0-9]{4}",
                                          generate: "/alligators/1234")

            animalMockService!.given("an alligator exists")
              .uponReceiving("a request for an alligator with path matcher")
              .withRequest(method:.GET, path: pathMatcher)
              .willRespondWith(status: 200,
                              headers: ["Content-Type": "application/json"],
                              body: ["name": "Mary", "type": "alligator"])

            //Run the tests
            animalMockService!.run { (testComplete) -> Void in
              animalServiceClient!.getAlligator(1234, success: { (alligator) in
                expect(alligator.name).to(equal("Mary"))
                testComplete()
              }, failure: { (error) in
                testComplete()
              })
            }
          }

          describe("With query params") {
            it("should return animals living in water") {
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
                  testComplete()
                })
              }
            }

            it("should return animals living in water using dictionary matcher") {
              animalMockService!.given("an alligator exists")
                .uponReceiving("a request for animals living in water with dictionary matcher")
                .withRequest(method:.GET, path: "/animals", query: ["live": testSetup.matcher.somethingLike("water")])
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
                  testComplete()
                })
              }
            }

            it("should return animals living in water using matcher") {
                let queryMatcher = ["live": testSetup.matcher.term(matcher: ".*", generate: "water")]

              animalMockService!.given("an alligator exists")
                .uponReceiving("a request for animals living in water with matcher")
                .withRequest(method:.GET, path: "/animals", query: queryMatcher)
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
                  testComplete()
                })
              }
            }
          }

          describe("With Header matches") {
            it("gets a secure alligator with auth header matcher") {
              animalMockService!.given("an alligator exists")
                .uponReceiving("a request for an alligator with header matcher")
                .withRequest(method: .GET,
                            path: "/alligators",
                            headers: ["Authorization": testSetup.matcher.somethingLike("OIOIUOIU")])
                .willRespondWith(status: 200,
                                headers: ["Content-Type": "application/json", "Etag": testSetup.matcher.somethingLike("x234")],
                                body: ["name": "Mary", "type": "alligator"])

              //Run the tests
              animalMockService!.run { (testComplete) -> Void in
                animalServiceClient!.getSecureAlligators(authToken: "OIOIUOIU", success: { (alligators) in
                  expect(alligators[0].name).to(equal("Mary"))
                  testComplete()
                }, failure: { (error) in
                  testComplete()
                }
                )
              }
            }
          }

          describe("PATCH request") {
            it("should unfriend me") {
              animalMockService!.given("Alligators and pidgeons exist")
                .uponReceiving("a request eat a pidgeon")
                .withRequest(method:.PATCH, path: "/alligator/eat", body: [ "type": "pidgeon" ])
                .willRespondWith(status: 204, headers: ["Content-Type": "application/json"])

              //Run the tests
              animalMockService!.run{ (testComplete) -> Void in
                animalServiceClient!.eat(animal: "pidgeon", success: { () in
                  testComplete()
                }, error: { (error) in
                  expect(true).to(equal(false))
                  testComplete()
                })
              }
            }
          }

          describe("Expecting an error response") {
            it("returns an error") {
              animalMockService!.given("Alligators don't eat pidgeons")
                .uponReceiving("a request to no longer eat pidgeons")
                .withRequest(method:.DELETE, path: "/alligator/eat", body: [ "type": "pidgeon" ])
                .willRespondWith(status:404, body: "No relationship")

              //Run the tests
              animalMockService!.run { (testComplete) -> Void in
                animalServiceClient!.wontEat(animal: "pidgeon", success: { () in
                  // We are expecting this test to fail - the error handler should be called
                  expect(true).to(equal(false))
                  testComplete()
                }, error: { (error) in
                  testComplete()
                })
              }
            }
          }

          describe("multiple interactions") {
            it("should allow multiple interactions in test setup") {
              animalMockService!.given("alligators don't each pidgeons")
                .uponReceiving("a request to eat")
                .withRequest(method:.PATCH, path: "/alligator/eat", body: ["type": "pidgeon"])
                .willRespondWith(status: 204, headers: ["Content-Type": "application/json"])
              animalMockService!.uponReceiving("what alligators eat")
                .withRequest(method:.GET, path: "/alligator/eat")
                .willRespondWith(status:200, headers: ["Content-Type": "application/json"], body: [ ["name": "Joseph", "type": testSetup.matcher.somethingLike("pidgeon")]])

              //Run the tests
              animalMockService!.run { (testComplete) -> Void in
                animalServiceClient!.eat(animal: "pidgeon", success: { () in
                  animalServiceClient!.eats { (response) in
                    expect(response.count).to(equal(1))
                    let name = response[0].name
                    let type = response[0].type
                    expect(name).to(equal("Joseph"))
                    expect(type).to(equal("pidgeon"))
                    testComplete()
                  }
                }, error: { (error) in
                  expect(true).to(equal(false))
                  testComplete()
                })
              }
            }
          }

          describe("Matchers") {
            it("Can match date based on regex") {
              animalMockService!.given("an alligator exists with a birthdate")
                .uponReceiving("a request for alligator with birthdate")
                .withRequest(method:.GET, path: "/alligators/123")
                .willRespondWith(
                  status: 200,
                  headers: ["Content-Type": "application/json"],
                  body: [
                    "name": "Mary",
                    "type": "alligator",
                    "dateOfBirth": testSetup.matcher.term(
                      matcher: "\\d{2}\\/\\d{2}\\/\\d{4}",
                      generate: "02/02/1999"
                    )
                  ])

              //Run the tests
              animalMockService!.run { (testComplete) -> Void in
                animalServiceClient!.getAlligator(123, success: { (alligator) in
                  expect(alligator.name).to(equal("Mary"))
                  expect(alligator.dob).to(equal("02/02/1999"))
                  testComplete()
                }, failure: { (error) in
                  expect(true).to(equal(false))
                  testComplete()
                })
              }
            }

            it("Can match legs based on type") {
              animalMockService!.given("an alligator exists with legs")
                .uponReceiving("a request for alligator with legs")
                .withRequest(method:.GET, path: "/alligators/1")
                .willRespondWith(
                  status: 200,
                  headers: ["Content-Type": "application/json"],
                  body: [
                    "name": "Mary",
                    "type": "alligator",
                    "legs": testSetup.matcher.somethingLike(4)
                  ])

              //Run the tests
              animalMockService!.run { (testComplete) -> Void in
                animalServiceClient!.getAlligator(1, success: { (alligator) in
                  expect(alligator.legs).to(equal(4))
                  testComplete()
                }, failure: { (error) in
                  expect(true).to(equal(false))
                  testComplete()
                })
              }
            }

              it("Can match based on flexible length array") {
                animalMockService!.given("multiple land based animals exist")
                  .uponReceiving("a request for animals living on land")
                  .withRequest(
                    method:.GET,
                    path: "/animals",
                    query: ["live": "land"])
                  .willRespondWith(
                    status: 200,
                    headers: ["Content-Type": "application/json"],
                    body: testSetup.matcher.eachLike(["name": "Bruce", "type": "wombat"], min: 5))

                //Run the tests
                animalMockService!.run { (testComplete) -> Void in
                  animalServiceClient!.findAnimals(live: "land", response: {
                    (response) in
                    expect(response.count).to(equal(5))
                    expect(response[0].name).to(equal("Bruce"))
                    testComplete()
                  })
              }
            }
          }
        }
      }
    }
  }
}
