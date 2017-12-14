import Quick
import Nimble
@testable import PactConsumerSwift
import SwiftyJSON

class PactHeaderBuilderSpec: QuickSpec {
  override func spec() {

    context("no matching rules") {
      let pactHeaders = PactHeaderBuilder(headers: [
        "Content-Type": "application/json",
        "Authorization": "alligator"]
        ).build()

        it("builds matching rules") {
          let matchingRules = JSON(pactHeaders.matchingRules)

          expect(matchingRules).to(equal([:]))
        }

        it("builds headers") {
          let headers = JSON(pactHeaders.headers)

          expect(headers).to(equal(["Content-Type": "application/json", "Authorization": "alligator"]))
        }
    }

    context("matching rules") {
      let pactHeaders = PactHeaderBuilder(headers: [
        "Content-Type": "application/json",
        "MyHeader": Matchers.somethingLike(3),
        "Authorization": Matchers.somethingLike("alligator")]
        ).build()

        it("builds matching rules") {
          let matchingRules = JSON(pactHeaders.matchingRules)

          expect(matchingRules).to(equal(["$.headers.Authorization": ["match": "type"], "$.headers.MyHeader": ["match": "type"]]))
        }

        it("builds headers") {
          let headers = JSON(pactHeaders.headers)

          expect(headers).to(equal(["Content-Type": "application/json",
            "MyHeader": 3,
            "Authorization": "alligator"]))
        }
    }
  }
}
