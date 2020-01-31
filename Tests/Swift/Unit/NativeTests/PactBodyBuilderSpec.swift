import Quick
import Nimble
@testable import PactConsumerSwift
import SwiftyJSON

class PactBodyBuilderSpec: QuickSpec {
  override func spec() {

    context("no matching rules") {
      let pactBody = PactBodyBuilder( body: [
        "name": "Mary",
        "type": "alligator",
        "friends": [ "Bob", "Jane" ]]
        ).build()

      it("builds matching rules") {
        let matchingRules = JSON(pactBody.matchingRules)

        expect(matchingRules).to(equal([:]))
      }

      it("builds json body") {
        let body = JSON(pactBody.body)

        expect(body).to(equal(["name": "Mary",
                               "type": "alligator",
                               "friends": [ "Bob", "Jane" ]]))
      }
    }

    context("constructs matcher in dictionary") {
      let pactBody = PactBodyBuilder( body: [
                                           "name": "Mary",
                                           "type": "alligator",
                                           "legs": NativeMatcher().somethingLike(4)]
        ).build()

      it("builds matching rules") {
        let matchingRules = JSON(pactBody.matchingRules)

        expect(matchingRules).to(equal(["$.body.legs": ["match": "type"]]))
      }

      it("builds json body") {
        let body = JSON(pactBody.body)

        expect(body).to(equal(["name": "Mary",
                               "type": "alligator",
                               "legs": 4]))
      }
    }

    context("constructs matcher in array") {
      let pactBody = PactBodyBuilder( body: [ "friends": [ NativeMatcher().somethingLike("Bob") ] ]
        ).build()

      it("builds matching rules") {
        let matchingRules = JSON(pactBody.matchingRules)

        expect(matchingRules).to(equal(["$.body.friends[0]": ["match": "type"]]))
      }

      it("builds json body") {
        let body = JSON(pactBody.body)

        expect(body).to(equal(["friends": [ "Bob" ] ]))
      }
    }

    context("only having friends like bob") {
        let bob = ["name": NativeMatcher().somethingLike("Bob"),
                   "age": NativeMatcher().term(matcher: "\\d{2}", generate: 30),
                   "cool": NativeMatcher().somethingLike(true)
        ]
        let minType = 2
        let pactBody = PactBodyBuilder(body: ["friends": NativeMatcher().eachLike(bob, min: minType)]).build()

        it("builds matching rules") {
          let matchingRules = JSON(pactBody.matchingRules)

          expect(matchingRules).to(equal([
            "$.body.friends[0][*].name": ["match": "type"],
            "$.body.friends[0][*].age": [
                "match": "regex",
                "regex": "\\d{2}"
            ],
            "$.body.friends[0][*].cool": ["match": "type"],
            "$.body.friends[0]": [
                "match": "type",
                "min": minType
            ],
          ]))
        }

        it("builds json body") {
          let body = JSON(pactBody.body)
          let bobBody: [String : Any] = [
            "name": "Bob",
            "age": 30,
            "cool": true
          ]
          expect(body).to(equal(["friends": [bobBody, bobBody]]))
        }
    }

    context("with multiple matches") {
      let pactBody = PactBodyBuilder( body: [
        "name": "Mary",
        "skills": [ [ "type": NativeMatcher().somethingLike("building"), "time": NativeMatcher().somethingLike("3 years") ] ],
        "relations": [ "friends": [ "Jane", NativeMatcher().somethingLike("Bob") ] ]]
        ).build()

      it("builds matching rules") {
        let matchingRules = JSON(pactBody.matchingRules)

        expect(matchingRules).to(equal([
          "$.body.relations.friends[1]": ["match": "type"] ,
          "$.body.skills[0].type": ["match": "type"] ,
          "$.body.skills[0].time": ["match": "type"]
        ]))
      }

      it("builds json body") {
        let body = JSON(pactBody.body)

        expect(body).to(equal([
          "name": "Mary",
          "skills": [ [ "type": "building", "time": "3 years" ] ],
          "relations": [ "friends": [ "Jane", "Bob" ] ] ]
        ))
      }
    }
  }
}
