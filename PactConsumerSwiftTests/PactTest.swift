
import Quick
import Nimble
import PactConsumerSwift

class HelloClientSpec: QuickSpec {
    override func spec() {
        it("is friendly") {
            var hello = "nothingHere"
            var helloProvider = MockService(provider: "Hello Provider", consumer: "Hello Consumer")

            helloProvider.uponReceiving("a request for hello")

            //Run the tests
            helloProvider.run { (complete) in
                HelloClient().sayHello { (response) in
                    hello = response
                }
                expect(hello).toEventually(contain("hello"))
                complete()
            }
        }
    }
}
