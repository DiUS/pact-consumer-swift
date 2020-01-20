import Quick
import Nimble
@testable import PactConsumerSwift

class InteractionSpec: QuickSpec {
  override func spec() {
    var interaction: Interaction?
    beforeEach { interaction = Interaction() }

    describe("json payload"){
      context("pact state") {
        it("includes provider state in the payload") {
          let payload = interaction!.given("state of awesomeness").uponReceiving("an important request is received").payload()

          expect(payload["providerState"] as! String?) == "state of awesomeness"
          expect(payload["description"] as! String?) == "an important request is received"
        }
      }

      context("no provider state") {
        it("doesn not include provider state when not included") {
          let payload = interaction!.uponReceiving("an important request is received").payload()

          expect(payload["providerState"]).to(beNil())
        }
      }

      context("request") {
        let method: PactHTTPMethod = .PUT
        let path = "/path"
        let headers = ["header": "value"]
        let body = "blah"

        it("returns expected request with specific headers and body") {
          let payload = interaction!.withRequest(method: method, path: path, headers: headers, body: body).payload()

          let request = payload["request"] as! [String: AnyObject]
          expect(request["path"] as! String?) == path
          expect(request["method"] as! String?).to(equal("put"))
          expect(request["headers"] as! [String: String]?).to(equal(headers))
          expect(request["body"] as! String?).to(equal(body))
        }

        it("returns expected request without body and headers") {
          let payload = interaction!.withRequest(method:method, path: path).payload()

          let request = payload["request"] as! [String: AnyObject]
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
          let payload = interaction!.willRespondWith(status: statusCode, headers: headers, body: body).payload()

          let request = payload["response"] as! [String: AnyObject]
          expect(request["status"] as! Int?) == statusCode
          expect(request["headers"] as! [String: String]?).to(equal(headers))
          expect(request["body"] as! String?).to(equal(body))
        }
      }
    }
  }
}
