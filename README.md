# Pact Consumer Swift
* Core Library build: [![Build Status](https://travis-ci.org/DiUS/pact-consumer-swift.svg)](https://travis-ci.org/DiUS/pact-consumer-swift)
* Swift, Carthage Example build: [![Swift, Carthage Example - Build Status](https://travis-ci.org/andrewspinks/PactSwiftExample.svg?branch=master)](https://travis-ci.org/andrewspinks/PactSwiftExample)
* ObjeciveC, Git Submodules Example build: [![Build Status](https://travis-ci.org/andrewspinks/PactObjectiveCExample.svg?branch=master)](https://travis-ci.org/andrewspinks/PactObjectiveCExample)

This library provides a Swift / Objective C DSL for creating Consumer [Pacts](http://pact.io).

Implements [Pact Specification v2](https://github.com/pact-foundation/pact-specification/tree/version-2),
including [flexible matching](http://docs.pact.io/documentation/matching.html).

This DSL relies on the Ruby [pact-mock_service][pact-mock-service] gem to provide the mock service for the tests.

## Installation

### Install the [pact-mock_service][pact-mock-service]
  `gem install pact-mock_service -v 0.9.0`

### Add the PactConsumerSwift library to your project

#### Using [Carthage](https://github.com/Carthage/Carthage) library manager
- See the [PactSwiftExample](https://github.com/andrewspinks/PactSwiftExample) for an example project using the library with Carthage.

#### Using CocoaPods

- See the [PactObjectiveCExample](https://github.com/andrewspinks/PactObjectiveCExample) for an example project using the library with CocoaPods.

## Writing Pact Tests

### Testing with Swift
  Write a Unit test similar to the following (NB: this example is using the [Quick](https://github.com/Quick/Quick) test framework)

```swift
import PactConsumerSwift

...
  beforeEach {
    animalMockService = MockService(provider: "Animal Service", consumer: "Animal Consumer Swift", done: { result in
      expect(result).to(equal(PactVerificationResult.Passed))
    })
    animalServiceClient = AnimalServiceClient(baseUrl: animalMockService!.baseUrl)
  }

  it("gets an alligator") {
    var complete: Bool = false

    animalMockService!.given("an alligator exists")
                      .uponReceiving("a request for an alligator")
                      .withRequest(method:.GET, path: "/alligator")
                      .willRespondWith(status:200,
                                       headers: ["Content-Type": "application/json"],
                                       body: ["name": "Mary"])

    //Run the tests
    animalMockService!.run { (testComplete) -> Void in
      animalServiceClient!.getAlligator { (alligator) in
        expect(alligator.name).to(equal("Mary"))
        complete = true
        testComplete()
      }
    }

    // Wait for asynch HTTP requests to finish
    expect(complete).toEventually(beTrue())
  }
```

### Testing with Objective-C
  Write a Unit test similar to the following
```objc
@import PactConsumerSwift;
...
- (void)setUp {
  [super setUp];
  XCTestExpectation *exp = [self expectationWithDescription:@"Pacts all verified"];
  self.animalMockService = [[MockService alloc] initWithProvider:@"Animal Provider"
                                                        consumer:@"Animal Service Client Objective-C"
                                                            done:^(PactVerificationResult result) {
    XCTAssert(result == PactVerificationResultPassed);
    [exp fulfill];
  }];
  self.animalServiceClient = [[OCAnimalServiceClient alloc] initWithBaseUrl:self.animalMockService.baseUrl];
}

- (void)testGetAlligator {
  typedef void (^CompleteBlock)();

  [[[[self.animalMockService given:@"an alligator exists"]
                             uponReceiving:@"oc a request for an alligator"]
                             withRequestHTTPMethod:PactHTTPMethodGET
                                              path:@"/alligator"
                                             query:nil headers:nil body:nil]
                             willRespondWithHTTPStatus:200
                                               headers:@{@"Content-Type": @"application/json"}
                                                  body: @"{ \"name\": \"Mary\"}" ];

  [self.animalMockService run:^(CompleteBlock testComplete) {
      Animal *animal = [self.animalServiceClient getAlligator];
      XCTAssertEqualObjects(animal.name, @"Mary");
      testComplete();
  }];

  [self waitForExpectationsWithTimeout:5 handler:nil];
}
```
### Matching

In addition to verbatim value matching, you have 3 useful matching functions
in the `Matcher` class that can increase expressiveness and reduce brittle test
cases.

* `Matcher.term(matcher, generate)` - tells Pact that the value should match using
a given regular expression, using `generate` in mock responses. `generate` must be
a string.
* `Matcher.somethingLike(content)` - tells Pact that the value itself is not important, as long
as the element _type_ (valid JSON number, string, object etc.) itself matches.
* `Matcher.eachLike(content, min)` - tells Pact that the value should be an array type,
consisting of elements like those passed in. `min` must be >= 1. `content` may
be a valid JSON value: e.g. strings, numbers and objects.

*NOTE*: One caveat to note, is that you will need to use valid Ruby
[regular expressions](http://ruby-doc.org/core-2.1.5/Regexp.html) and double
escape backslashes.

See the `PactSpecs.swift`, `PactObjectiveCTests.m` for examples on how to expect error responses, how to use query params, and the Matchers.

For more on request / response matching, see [Matching](http://docs.pact.io/documentation/matching.html).

### Verifying your iOS client against the service you are integrating with
If your setup is correct and your tests run against the pack mock server, then you should see a log file here:
`$YOUR_PROJECT/tmp/pact.log`
And the generated pacts, here:
`$YOUR_PROJECT/tmp/pacts/...`

  See [Verifying pacts](http://docs.pact.io/documentation/verifying_pacts.html) for more information.

For an end to end example with a ruby back end service, have a look at the [KatKit example](https://github.com/andrewspinks/pact-mobile-preso)

# More reading
* The Pact website [Pact](http://pact.io)
* The pact mock server that the Swift library uses under the hood [Pact mock service](https://github.com/bethesque/pact-mock_service)
* A pact broker for managing the generated pact files (so you don't have to manually copy them around!) [Pact broker](https://github.com/bethesque/pact_broker)

# Contributing

Please read [CONTRIBUTING.md](/CONTRIBUTING.md)

[pact-readme]: https://github.com/realestate-com-au/pact
[pact-mock-service]: https://github.com/bethesque/pact-mock_service
[pact-mock-service-without-ruby]: https://github.com/DiUS/pact-consumer-js-dsl/wiki/Using-the-Pact-Mock-Service-without-Ruby
