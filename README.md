# Pact Consumer Swift
* Core Library build: [![Build Status](https://travis-ci.org/DiUS/pact-consumer-swift.svg)](https://travis-ci.org/DiUS/pact-consumer-swift)
* Swift, Carthage Example build: [![Swift, Carthage Example - Build Status](https://travis-ci.org/andrewspinks/PactSwiftExample.svg?branch=master)](https://travis-ci.org/andrewspinks/PactSwiftExample)
* ObjeciveC, Git Submodules Example build: [![Build Status](https://travis-ci.org/andrewspinks/PactObjectiveCExample.svg?branch=master)](https://travis-ci.org/andrewspinks/PactObjectiveCExample)

_This DSL is in very early stages of development, please bear with us as we give it some polish. Please raise any problems you have in the github issues._

This codebase provides a iOS DSL for creating pacts. If you are new to Pact, please read the Pact [README][pact-readme] first.

This DSL relies on the Ruby [pact-mock_service][pact-mock-service] gem to provide the mock service for the iOS tests.

## Installation

### Install the [pact-mock_service][pact-mock-service]
  `gem install pact-mock_service -v 0.3.0`

### Add the PactConsumerSwift library to your project

#### Using [Carthage](https://github.com/Carthage/Carthage) library manager
- See the [PactSwiftExample](https://github.com/andrewspinks/PactSwiftExample) for an example project using the library with Carthage.

#### Using Git Submodules

- See the [PactObjectiveCExample](https://github.com/andrewspinks/PactObjectiveCExample) for an example project using the library with git submodules.

## Writing Pact Tests

### Testing with Swift
  Write a Unit test similar to the following

```swift
import PactConsumerSwift

...
  override func setUp() {
    super.setUp()
    let expectation = expectationWithDescription("Pacts are verified")
    helloProvider = MockService(provider: "Hello Provider", consumer: "Hello Consumer", done: { result in
      XCTAssertEqual(result, PactVerificationResult.Passed)
      expectation!.fulfill()
    })
    helloClient = HelloClient(baseUrl: helloProvider!.baseUrl)
  }

  func testItSaysHello() {
    var hello = "not Goodbye"
    helloProvider!.uponReceiving("a request for hello")
                  .withRequest(method: .GET, path: "/sayHello")
                  .willRespondWith(status: 200, headers: ["Content-Type": "application/json"], body: ["reply": "Hello"])

    //Run the tests
    helloProvider!.run{ (testComplete) -> Void in
      self.helloClient!.sayHello { (response) in
        XCTAssertEqual(response, "Hello")
        testComplete()
      }
    }

    waitForExpectationsWithTimeout(10) { (error) in }
  }
```
  See the specs in the iOS Swift Example directory for examples of asynchronous callbacks, how to expect error responses, and how to use query params.

### Testing with Objective-C
  Write a Unit test similar to the following
```objc
@import PactConsumerSwift;
...
- (void)setUp {
  [super setUp];
  XCTestExpectation *exp = [self expectationWithDescription:@"Pacts all verified"];
  self.mockService = [[MockService alloc] initWithProvider:@"Provider" consumer:@"consumer" done:^(PactVerificationResult result) {
    XCTAssert(result == PactVerificationResultPassed);
    [exp fulfill];
  }];
  self.helloClient = [[HelloClient alloc] initWithBaseUrl:self.mockService.baseUrl];
}

- (void)testItSaysHello {
  typedef void (^CompleteBlock)();
  [[[self.mockService uponReceiving:@"a request for hello"]
                 withRequestHTTPMethod:PactHTTPMethodGET path:@"/sayHello" query:nil headers:nil body: nil]
                 willRespondWithHTTPStatus:200 headers:@{@"Content-Type": @"application/json"} body: @"Hello" ];

  [self.mockService run:^(CompleteBlock testComplete) {
      NSString *requestReply = [self.helloClient sayHello];
      XCTAssertEqualObjects(requestReply, @"Hello");
      testComplete();
    }
  ];

  [self waitForExpectationsWithTimeout:5 handler:nil];
}
```

### Verifying your iOS client against the service you are integrating with
If your setup is correct and your tests run against the pack mock server, then you should see a log file here:
`$YOUR_PROJECT/tmp/pact.log`
And the generated pacts, here:
`$YOUR_PROJECT/tmp/pacts/...`

# Contributing

Please read [CONTRIBUTING.md](/CONTRIBUTING.md)

[pact-readme]: https://github.com/realestate-com-au/pact
[pact-mock-service]: https://github.com/bethesque/pact-mock_service
[pact-mock-service-without-ruby]: https://github.com/DiUS/pact-consumer-js-dsl/wiki/Using-the-Pact-Mock-Service-without-Ruby