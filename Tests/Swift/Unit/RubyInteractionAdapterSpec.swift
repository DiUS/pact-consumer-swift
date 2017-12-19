import Quick
import Nimble
@testable import PactConsumerSwift

class RubyInteractionAdapterSpec: QuickSpec {
  override func spec() {
    var interaction: Interaction?
    beforeEach { interaction = Interaction() }

    describe("interaction state setup") {
      it("it initialises the provider state") {
        expect(interaction?.given("some state").providerState).to(equal("some state"))
      }
    }

    describe("json payload") {
      context("pact state") {
        it("includes provider state in the payload") {
          var payload = RubyInteractionAdapter(interaction!.given("state of awesomeness").uponReceiving("an important request is received")).adapt()

          expect(payload["providerState"] as! String?) == "state of awesomeness"
          expect(payload["description"] as! String?) == "an important request is received"
        }
      }

      context("no provider state") {
        it("doesn not include provider state when not included") {
          var payload = RubyInteractionAdapter(interaction!.uponReceiving("an important request is received")).adapt()

          expect(payload["providerState"]).to(beNil())
        }
      }

      context("request") {
        let method: PactHTTPMethod = .PUT
        let path = "/path"
        let headers = ["header": "value"]
        let body = "blah"

        it("returns expected request with specific headers and body") {
          var payload = RubyInteractionAdapter(interaction!.withRequest(method: method, path: path, headers: headers, body: body)).adapt()

          var request = payload["request"] as! [String: AnyObject]
          expect(request["path"] as! String?) == path
          expect(request["method"] as! String?).to(equal("put"))
          expect(request["headers"] as! [String: String]?).to(equal(headers))
          expect(request["body"] as! String?).to(equal(body))
        }

        it("returns expected request without body and headers") {
          var payload = RubyInteractionAdapter(interaction!.withRequest(method:method, path: path)).adapt()

          var request = payload["request"] as! [String: AnyObject]
          expect(request["path"] as! String?) == path
          expect(request["method"] as! String?).to(equal("put"))
          expect(request["headers"] as! [String: String]?).to(beNil())
          expect(request["body"] as! String?).to(beNil())
        }
      }

      context("response") {
        let statusCode = 200
        let headers = ["header": "value"]
        let body = "body"

        it("returns expected response with specific headers and body") {
          var payload = RubyInteractionAdapter(interaction!.willRespondWith(status: statusCode, headers: headers, body: body)).adapt()

          var request = payload["response"] as! [String: AnyObject]
          expect(request["status"] as! Int?) == statusCode
          expect(request["headers"] as! [String: String]?).to(equal(headers))
          expect(request["body"] as! String?).to(equal(body))
        }
      }
    }
  }
}
