# Pact Consumer Swift
* Core Library build: [![Build Status](https://travis-ci.org/DiUS/pact-consumer-swift.svg)](https://travis-ci.org/DiUS/pact-consumer-swift)
* Swift, Carthage Example build: [![Swift, Carthage Example - Build Status](https://travis-ci.org/andrewspinks/PactSwiftExample.svg?branch=master)](https://travis-ci.org/andrewspinks/PactSwiftExample)
* ObjeciveC, Git Submodules Example build: [![Build Status](https://travis-ci.org/andrewspinks/PactObjectiveCExample.svg?branch=master)](https://travis-ci.org/andrewspinks/PactObjectiveCExample)

_This DSL is in very early stages of development, please bear with us as we give it some polish. Please raise any problems you have in the github issues._

This codebase provides a iOS DSL for creating pacts. If you are new to Pact, please read the Pact [README][pact-readme] first.

This DSL relies on the Ruby [pact-mock_service][pact-mock-service] gem to provide the mock service for the iOS tests.

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
  See the PactSpecs.swift for examples on how to expect error responses, how to use query params, etc.

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

### Verifying your iOS client against the service you are integrating with
If your setup is correct and your tests run against the pack mock server, then you should see a log file here:
`$YOUR_PROJECT/tmp/pact.log`
And the generated pacts, here:
`$YOUR_PROJECT/tmp/pacts/...`

For an end to end example with a ruby back end service, have a look at the [KatKit example](https://github.com/andrewspinks/pact-mobile-preso)

# More reading
* The original pact library, with lots of background and guidelines [Pact](https://github.com/realestate-com-au/pact)
* The pact mock server that the Swift library uses under the hood [Pact mock service](https://github.com/bethesque/pact-mock_service)
* A pact broker for managing the generated pact files (so you don't have to manually copy them around!) [Pact broker](https://github.com/bethesque/pact_broker)

# Contributing

Please read [CONTRIBUTING.md](/CONTRIBUTING.md)

[pact-readme]: https://github.com/realestate-com-au/pact
[pact-mock-service]: https://github.com/bethesque/pact-mock_service
[pact-mock-service-without-ruby]: https://github.com/DiUS/pact-consumer-js-dsl/wiki/Using-the-Pact-Mock-Service-without-Ruby
