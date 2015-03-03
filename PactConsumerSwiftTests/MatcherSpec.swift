import Quick
import Nimble
import PactConsumerSwift

class MatcherSpec: QuickSpec {
  override func spec() {

    /*
      NB: Pact version 1 matchers are ruby specific, so they will only work when verifying agains a server with the
      ruby gem.
    */
    describe("pact version 1 matchers"){

      describe("regex matcher") {

        it("sets the regular expressiont to match against") {
          var regex = "\\d{16}"
          var matcher = Matcher.term(matcher: regex, generate: "1111222233334444")

          var matcherRegex = ""
          if let data = matcher["data"] as? [String: AnyObject] {
            if let matcher = data["matcher"] as? [String: AnyObject] {
              matcherRegex = matcher["s"] as String
            }
          }
          expect(matcherRegex).to(equal(regex))
        }

        it("sets the default value to returnt") {
          var placeholder = "1111222233334444"
          var matcher = Matcher.term(matcher: "\\d{16}", generate: placeholder)

          var generate = ""
          if let data = matcher["data"] as? [String: AnyObject] {
            generate = data["generate"] as String
          }
          expect(generate).to(equal(placeholder))
        }
      }
    }

    describe("type matcher") {

      it("sets the regular expressiont to match against") {
        var matcher = Matcher.somethingLike(1234)

        var likeThis = matcher["contents"] as? Int
        expect(likeThis).to(equal(1234))
      }

    }
  }
}
