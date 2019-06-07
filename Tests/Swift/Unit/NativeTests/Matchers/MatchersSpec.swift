import Quick
import Nimble
import PactConsumerSwift

class NativeMatcherSpec: QuickSpec {
  override func spec() {
    describe("regex matcher") {
      let regex = "\\d{16}"
      let placeholder = "1111222233334444"
      let subject = NativeMatcher().term(matcher: regex, generate: placeholder) as! MatchingRule
      it("rule matches term and contains regex") {
        expect(subject.rule() as NSDictionary).to(equal(
            ["match": "regex",
            "regex": regex] as NSDictionary
        ))
      }

      it("has the generator as value") {
        let value = subject.value() as! String
        expect(value).to(equal("1111222233334444"))
      }
    }

    describe("type matcher") {
      let subject = NativeMatcher().somethingLike(1234) as! MatchingRule

      it("has a type rule") {
        expect(subject.rule() as NSDictionary).to(equal(
            ["match": "type"] as NSDictionary
        ))
      }

      it("has a value") {
        let value = subject.value() as! Int
        expect(value).to(equal(1234))
      }
    }

    describe("minType matcher") {
        let example: [String : Any] = ["key1": 5, "key2": "value"]
        let subject = NativeMatcher().eachLike(example, min: 2) as! MatchingRule

        it("has a minType rule") {
            expect(subject.rule() as NSDictionary).to(equal(
                [ "match": "type",
                "min": 2] as NSDictionary
            ))
        }

        it("has example as value") {
            let value = subject.value() as! NSDictionary
            expect(value).to(equal(example as NSDictionary))
        }
    }
  }
}
