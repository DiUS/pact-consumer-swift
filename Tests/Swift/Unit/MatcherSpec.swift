import Quick
import Nimble
import PactConsumerSwift

class MatcherSpec: QuickSpec {

  override func spec() {

    describe("regex matcher") {
      let regex = "\\d{16}"
      let placeholder = "1111222233334444"
      let subject = Matcher.term(matcher: regex, generate: placeholder) as! [String: Any]

      it("sets the json_class") {
        let className = subject["json_class"] as? String
        expect(className).to(equal("Pact::Term"))
      }

      it("sets the regular expression to match against") {
        let data = subject["data"] as? [String: AnyObject]
        let matcher = data?["matcher"] as? [String: AnyObject]
        let matcherRegex = matcher?["s"] as! String

        expect(matcherRegex).to(equal(regex))
      }

      it("sets the default value to return") {
        let data = subject["data"] as? [String: AnyObject]
        let generate = data?["generate"] as! String

        expect(generate).to(equal(placeholder))
      }
    }

    describe("type matcher") {
      let subject = Matcher.somethingLike(1234) as! [String: Any]

      it("sets the json_class") {
        let className = subject["json_class"] as? String
        expect(className).to(equal("Pact::SomethingLike"))
      }

      it("sets the regular expressiont to match against") {
        let likeThis = subject["contents"] as? Int
        expect(likeThis).to(equal(1234))
      }
    }

    describe("eachLike matcher") {
      let arrayItem = ["blah": "blow"]
      var subject = Matcher.eachLike(arrayItem) as! [String: Any]

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
        subject = Matcher.eachLike(arrayItem, min: 4) as! [String: Any]

        let min = subject["min"] as? Int
        expect(min).to(equal(4))
      }
    }
  }
}
