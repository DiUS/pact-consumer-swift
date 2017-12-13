import Quick
import Nimble
@testable import PactConsumerSwift
import SwiftyJSON

class PactQueryBuilderSpec: QuickSpec {
  override func spec() {

    context("dictionary based query") {
      context("no matching rules") {
        let pactQuery = PactQueryBuilder(query: [
          "name": "Mary",
          "type": "alligator"]
          ).build()

        it("builds matching rules") {
          let matchingRules = JSON(pactQuery.matchingRules)

          expect(matchingRules).to(equal([:]))
        }

        it("builds query") {
          let query = JSON(pactQuery.query)

          expect(query).to(equal("name=Mary&type=alligator"))
        }
      }

      context("matching rules") {
        let pactQuery = PactQueryBuilder(query: [
          "name": Matchers.somethingLike(3),
          "type": Matchers.somethingLike("alligator")]
          ).build()

        it("builds matching rules") {
          let matchingRules = JSON(pactQuery.matchingRules)

          expect(matchingRules).to(equal(["$.query.name[0]": ["match": "type"], "$.query.type[0]": ["match": "type"]]))
        }

        it("builds query") {
          let query = JSON(pactQuery.query)

          expect(query).to(equal("name=3&type=alligator"))
        }
      }
    }

    context("string based query") {
      let pactQuery = PactQueryBuilder(query: "live=water").build()

      it("builds matching rules") {
        let matchingRules = JSON(pactQuery.matchingRules)

        expect(matchingRules).to(equal([:]))
      }

      it("builds query") {
        let query = JSON(pactQuery.query)

        expect(query).to(equal("live=water"))
      }
    }

    context("matcher based query") {
      let matcher = Matchers.term("live=*", generate: "live=water")
      let pactQuery = PactQueryBuilder(query: matcher).build()

      it("builds matching rules") {
        let matchingRules = JSON(pactQuery.matchingRules)

        expect(matchingRules).to(equal(["$.query": ["match": "regex", "regex": "live=*"]]))
      }

      it("builds query") {
        let query = JSON(pactQuery.query)

        expect(query).to(equal("live=water"))
      }
    }
  }
}
