# Pact Consumer Swift

_This DSL is in very early stages of development, please bear with us as we give it some polish. Please raise any problems you have in the github issues.

This codebase provides a iOS DSL for creating pacts. If you are new to Pact, please read the Pact [README](pact-readme) first.

This DSL relies on the Ruby [pact-mock_service][pact-mock-service] gem to provide the mock service for the iOS tests.

### Getting Started

1. Install the [pact-mock_service](https://github.com/bethesque/pact-mock_service) ruby gem

   The easiest way is to add `gem 'pact-mock_service', '~> 0.2.3.pre.rc1'` to your `Gemfile` and run `bundle install`

1. Add the PactConsumerSwift library to your project

  1. Create a `package.json` if you don't have one already - use `npm init` if you don't


1. Write a Unit test similar to the following (Quick syntax),

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

1. Setup XCode to run the pact server with the tests
   *

# Contributing

Please read [CONTRIBUTING.md](/CONTRIBUTING.md)

[pact-readme]: https://github.com/realestate-com-au/pact
[pact-mock-service]: https://github.com/bethesque/pact-mock_service
[pact-mock-service-without-ruby]: https://github.com/DiUS/pact-consumer-js-dsl/wiki/Using-the-Pact-Mock-Service-without-Ruby