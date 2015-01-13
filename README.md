# Pact Consumer Swift

_This DSL is in very early stages of development, please bear with us as we give it some polish. Please raise any problems you have in the github issues._

This codebase provides a iOS DSL for creating pacts. If you are new to Pact, please read the Pact [README][pact-readme] first.

This DSL relies on the Ruby [pact-mock_service][pact-mock-service] gem to provide the mock service for the iOS tests.

### Getting Started

1. Install the [pact-mock_service][pact-mock-service]

  `sudo gem install pact-mock_service -v 0.2.3.pre.rc2`

1. Add the PactConsumerSwift library to your project

1. Setup your Test Target to run the pact server
  * Product -> Scheme -> Edit Scheme
    - Edit your test Scheme
  * Under Test, Pre-actions add a Run Script Action
    - "$SRCROOT"/Vendor/PactConsumerSwift/script/start_server.sh
    - make sure you provide the build settings from your project, otherwise SRCROOT will not be set
  * Under Test, Post-actions add a Run Script Action
    - "$SRCROOT"/Vendor/PactConsumerSwift/script/stop_server.sh
    - make sure you provide the build settings from your project, otherwise SRCROOT will not be set

1. Testing with Swift
  1. Write a Unit test similar to the following [XCTest],
    ...

  1. Write a Unit test similar to the following [Quick][https://github.com/Quick/Quick],

          it("it says Hello") {
              var hello = "not Goodbye"
              var helloProvider = MockService(provider: "Hello Provider", consumer: "Hello Consumer")

              helloProvider.uponReceiving("a request for hello")
                           .withRequest(.GET, path: "/sayHello")
                           .willRespondWith(200, headers: ["Content-Type": "application/json"], body: [ "reply": "Hello"])

              //Run the tests
              helloProvider.run ( { (complete) -> Void in
                HelloClient(baseUrl: helloProvider.baseUrl).sayHello { (response) in
                  hello = response
                  complete()
                }
              }, result: { (verification) -> Void in
                expect(verification).to(equal(VerificationResult.PASSED))
              })

              expect(hello).toEventually(contain("Hello"))
            }

      See the specs in the iOS Swift Example directory for examples of asynchronous callbacks, how to expect error responses, and how to use query params.

1. Testing with Objective C
  1. Write a Unit test similar to the following [XCTest],
    ....
  1. Write a Unit test similar to the following [Kiwi],
    ....

1. Verifying your client against the service you are integrating with

# Contributing

Please read [CONTRIBUTING.md](/CONTRIBUTING.md)

[pact-readme]: https://github.com/realestate-com-au/pact
[pact-mock-service]: https://github.com/bethesque/pact-mock_service
[pact-mock-service-without-ruby]: https://github.com/DiUS/pact-consumer-js-dsl/wiki/Using-the-Pact-Mock-Service-without-Ruby