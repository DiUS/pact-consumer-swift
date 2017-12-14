import Quick
import Nimble
import PactConsumerSwift

class MatchersSpec: QuickSpec {
  override func spec() {
    describe("regex matcher") {
      let regex = "\\d{16}"
      let placeholder = "1111222233334444"
      let subject = Matchers.term(regex, generate: placeholder)

      it("rule matches term and contains regex") {
        expect(subject.rule()).to(equal(
          ["match": "regex",
          "regex": regex]
        ))
      }

      it("has the generator as value") {
        let value = subject.value() as! String
        expect(value).to(equal("1111222233334444"))
      }
    }

    describe("type matcher") {
      let subject = Matchers.somethingLike(1234)

      it("has a type rule") {
        expect(subject.rule()).to(equal(["match": "type"]))
      }

      it("has a value") {
        let value = subject.value() as! Int
        expect(value).to(equal(1234))
      }
    }

    describe("eachLike matcher") {
      let arrayItem = ["blah": "blow"]
      var subject = Matchers.eachLike(arrayItem)

      it("sets the json_class") {
        let className = subject["json_class"] as? String
        expect(className).to(equal("Pact::ArrayLike"))
      }

      it("sets array content to match against") {
        let contents = subject["contents"] as? [String: String]
        expect(contents).to(equal(arrayItem))
      }

      it("defaults the minimum required in array to 1") {
        let min = subject["min"] as? Int
        expect(min).to(equal(1))
      }

      it("allows min to be specified") {
        subject = Matchers.eachLike(arrayItem, min: 4)

        let min = subject["min"] as? Int
        expect(min).to(equal(4))
      }
    }
  }
}
