import Quick
import Nimble
@testable import PactConsumerSwift
import SwiftyJSON

class PactInteractionAdapterSpec: QuickSpec {
  override func spec() {
    var interaction: Interaction?

    beforeEach { interaction = Interaction() }

    describe("interaction state setup") {
      it("it initialises the provider state") {
        expect(interaction?.given("some state").providerState).to(equal("some state"))
      }
    }

    describe("json payload"){
      context("pact state") {
        it("includes provider state in the payload") {
          let payload = PactInteractionAdapter(interaction!.given("state of awesomeness").uponReceiving("an important request is received")).adapt()

          expect(payload["providerState"] as! String?) == "state of awesomeness"
          expect(payload["description"] as! String?) == "an important request is received"
        }
      }

      context("no provider state") {
        it("doesn not include provider state when not included") {
          let payload = PactInteractionAdapter(interaction!.uponReceiving("an important request is received")).adapt()

          expect(payload["providerState"]).to(beNil())
        }
      }

      context("request") {
        let method: PactHTTPMethod = .PUT
        let path = "/path"
        let headers = ["header": "value"]
        let body = "blah"
        let regex = "^/resource/[0-9]*"

        it("returns expected request with specific headers and body") {
          let payload = PactInteractionAdapter(interaction!.withRequest(method: method, path: path, headers: headers, body: body)).adapt()

          let request = payload["request"] as! [String: AnyObject]
          expect(request["path"] as! String?) == path
          expect(request["method"] as! String?).to(equal("put"))
          expect(request["headers"] as! [String: String]?).to(equal(headers))
          expect(request["body"] as! String?).to(equal(body))
        }

        it("returns expected request without body and headers") {
          let payload = PactInteractionAdapter(interaction!.withRequest(method: method, path: path)).adapt()

          let request = payload["request"] as! [String: AnyObject]
          expect(request["path"] as! String?) == path
          expect(request["method"] as! String?).to(equal("put"))
          expect(request["headers"] as! [String: String]?).to(beNil())
          expect(request["body"] as! String?).to(beNil())
        }

        context("with query params") {
          it("accepts single query param in dictionary") {
            let payload = PactInteractionAdapter(interaction!.withRequest(method: method, path: path, query: ["live": "water"])).adapt()

            let request = payload["request"] as! [String: AnyObject]
            expect(request["query"] as! String?) == "live=water"
          }

          it("accepts multiple query params in dictionary") {
            let payload = PactInteractionAdapter(interaction!.withRequest(method: method, path: path, query: ["live": "water", "age": 10])).adapt()

            let request = payload["request"] as! [String: AnyObject]
            expect(request["query"] as! String?) == "age=10&live=water"
          }

          it("accepts query params as string") {
            let payload = PactInteractionAdapter(interaction!.withRequest(method: method, path: path, query: "live=water")).adapt()

            let request = payload["request"] as! [String: AnyObject]
            expect(request["query"] as! String?) == "live=water"
          }

          context("with matchers") {
            var request : [String: Any]?

            beforeEach {
              interaction!.withRequest(method: method, path: path, query: ["live": NativeMatcher().somethingLike("water")])
              request = PactInteractionAdapter(interaction!).adapt()["request"] as? [String: Any]
            }

            it("accepts query parameter with a matcher") {
              expect(request!["query"] as! String?) == "live=water"
            }

            it("builds matching rules") {
              let matchingRules = JSON(request!["matchingRules"]!)
              expect(matchingRules).to(equal(["$.query.live[0]": ["match": "type"]]))
            }
          }
        }

        context("with header matcher") {
          let headers = ["Authorization": NativeMatcher().somethingLike("somekey")]
          var request : [String: Any]?

          beforeEach {
            interaction!.withRequest(method: method, path: path, headers: headers, body: body)
            request = PactInteractionAdapter(interaction!).adapt()["request"] as? [String: Any]
          }

          it("builds matching rules") {
            let matchingRules = JSON(request!["matchingRules"]!)
            expect(matchingRules).to(equal(["$.headers.Authorization": ["match": "type"]]))
          }

          it("adds default value to headers") {
            let headers = JSON(request!["headers"]!)
            expect(headers).to(equal(["Authorization": "somekey"]))
          }
        }

        context("with path matcher") {
          let path = NativeMatcher().term(matcher: regex, generate: "/resource/1")
          var request : [String: Any]?

          beforeEach {
            interaction!.withRequest(method: method, path: path, headers: headers, body: body)
            request = PactInteractionAdapter(interaction!).adapt()["request"] as? [String: Any]
          }

          it("builds matching rules") {
            let matchingRules = JSON(request!["matchingRules"]!)
            expect(matchingRules).to(equal(["$.path": ["match": "regex", "regex": regex]]))
          }

          it("adds default value to path") {
            let generatedPath = JSON(request!["path"]!)
            expect(generatedPath).to(equal("/resource/1"))
          }
        }

        context("body with matcher") {
          let body  = [
                  "type": "alligator",
                  "legs": NativeMatcher().somethingLike(4)] as [String : Any]
          var request : [String: Any]?

          beforeEach {
            interaction!.withRequest(method: method, path: path, headers: headers, body: body)
            request = PactInteractionAdapter(interaction!).adapt()["request"] as? [String: Any]
          }

          it("builds matching rules") {
            let matchingRules = JSON(request!["matchingRules"]!)
            expect(matchingRules).to(equal(["$.body.legs": ["match": "type"]]))
          }

          it("adds default value to body") {
            let generatedBody = JSON(request!["body"]!)
            expect(generatedBody).to(equal(["type": "alligator", "legs": 4]))
          }

          context("and path matcher") {
            let path = NativeMatcher().term(matcher: regex, generate: "/resource/1")

            beforeEach {
              interaction!.withRequest(method: method, path: path, headers: headers, body: body)
              request = PactInteractionAdapter(interaction!).adapt()["request"] as? [String: Any]
            }

            it("includes both matching rules") {
              let matchingRules = JSON(request!["matchingRules"]!)
              expect(matchingRules["$.body.legs"]).to(equal(["match": "type"]))
              expect(matchingRules["$.path"]).to(equal(["match": "regex", "regex": regex]))
            }
          }
        }
      }

      context("response") {
        let statusCode = 200
        let headers = ["header": "value"]
        let body = "body"
        var response : [String: Any]?

        it("returns expected response with specific headers and body") {
          let payload = PactInteractionAdapter(interaction!.willRespondWith(status: statusCode, headers: headers, body: body)).adapt()

          response = payload["response"] as! [String: AnyObject]
          expect(response!["status"] as! Int?) == statusCode
          expect(response!["headers"] as! [String: String]?).to(equal(headers))
          expect(response!["body"] as! String?).to(equal(body))
        }

        context("body with matcher") {
          let body  = [
            "type": "alligator",
            "legs": NativeMatcher().somethingLike(4)] as [String : Any]

          beforeEach {
            interaction!.willRespondWith(status: statusCode, headers: headers, body: body)
            response = PactInteractionAdapter(interaction!).adapt()["response"] as? [String: Any]
          }

          it("builds matching rules") {
            let matchingRules = JSON(response!["matchingRules"]!)
            expect(matchingRules).to(equal(["$.body.legs": ["match": "type"]]))
          }

          it("adds default value to body") {
            let generatedBody = JSON(response!["body"]!)
            expect(generatedBody).to(equal(["type": "alligator", "legs": 4]))
          }
        }

        context("with header matcher") {
          let headers = ["Authorization": NativeMatcher().somethingLike("somekey")]

          beforeEach {
            interaction!.willRespondWith(status: statusCode, headers: headers, body: body)
            response = PactInteractionAdapter(interaction!).adapt()["response"] as? [String: Any]
          }

          it("builds matching rules") {
            let matchingRules = JSON(response!["matchingRules"]!)
            expect(matchingRules).to(equal(["$.headers.Authorization": ["match": "type"]]))
          }

          it("adds default value to headers") {
            let headers = JSON(response!["headers"]!)
            expect(headers).to(equal(["Authorization": "somekey"]))
          }
        }
      }
    }
  }
}
