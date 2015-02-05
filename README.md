# Pact Consumer Swift
[![Build Status](https://travis-ci.org/DiUS/pact-consumer-swift.svg)](https://travis-ci.org/DiUS/pact-consumer-swift)

[![Swift, Carthage Example - Build Status](https://travis-ci.org/andrewspinks/PactSwiftExample.svg?branch=master)](https://travis-ci.org/andrewspinks/PactSwiftExample)

_This DSL is in very early stages of development, please bear with us as we give it some polish. Please raise any problems you have in the github issues._

This codebase provides a iOS DSL for creating pacts. If you are new to Pact, please read the Pact [README][pact-readme] first.

This DSL relies on the Ruby [pact-mock_service][pact-mock-service] gem to provide the mock service for the iOS tests.

## Installation

### Install the [pact-mock_service][pact-mock-service]
  `gem install pact-mock_service -v 0.2.4`

### Add the PactConsumerSwift library to your project

#### Using [Carthage](https://github.com/Carthage/Carthage) library manager
- See the [PactSwiftExample](https://github.com/andrewspinks/PactSwiftExample) for an example project using the library with Carthage.

#### Using Git Submodules

```sh
mkdir Vendor # you can keep your submodules in their own directory
git submodule add git@github.com:DiUS/pact-consumer-swift.git Vendor/pact-consumer-swift
git submodule update --init --recursive
```
_NB: I will be looking at better ways of integrating the project in the future._

#### Add `PactConsumerSwift.xcodeproj` and dependencies to your test target

Right-click on the group containing your application's tests and
select `Add Files To YourApp...`.

Next, select `PactConsumerSwift.xcodeproj`, from `Vendor/pact-consumer-swift`

Do the same process for the following dependencies:
* `Alamofire.xcodeproj`, from `Vendor/pact-consumer-swift/Carthage/Checkout/Alamofire/`
* `Quick.xcodeproj`, from `Vendor/pact-consumer-swift/Carthage/Checkout/Quick/`
* `Nimble.xcodeproj`, from `Vendor/pact-consumer-swift/Carthage/Checkout/Nimble/`

Once you've added the dependent projects, you should see it in Xcode's project navigator, grouped with your tests.

![](http://i.imgur.com/s6uBK1j.png)

#### Link `PactConsumerSwift.framework`

 Link the `PactConsumerSwift.framework` during your test target's
`Link Binary with Libraries` build phase.

![](http://i.imgur.com/Qrif7eo.png)

#### Setup your Test Target to run the pact server before the tests are run
  Modify the Test Target's scheme to add scripts to start and stop the pact server when tests are run.
  * From the menu `Product` -> `Scheme` -> `Edit Scheme`
    - Edit your test Scheme
  * Under Test, Pre-actions add a Run Script Action
    ```bash
    PATH=/path/to/pact-mock-service/binary:$PATH
    "$SRCROOT"/Vendor/pact-consumer-swift/scripts/start_server.sh
    ```
    - Make sure you select your project under `Provide the build settings from`, otherwise SRCROOT will not be set which the scripts depend on

  ![](http://i.imgur.com/asn8G1P.png)
  * Under Test, Post-actions add a Run Script Action
    ```bash
    PATH=/path/to/pact-mock-service/binary:$PATH
    "$SRCROOT"/Vendor/pact-consumer-swift/scripts/stop_server.sh
    ```
    - Make sure you select your project under `Provide the build settings from`, otherwise SRCROOT will not be set which the scripts depend on

## Writing Pact Tests

### Testing with Swift
  Write a Unit test similar to the following (NB: this is using [Quick](https://github.com/Quick/Quick) test runner)

```swift
import PactConsumerSwift

...

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
```
  See the specs in the iOS Swift Example directory for examples of asynchronous callbacks, how to expect error responses, and how to use query params.

### Testing with Objective-C
  Write a Unit test similar to the following
```objc
@import PactConsumerSwift;
...
- (void)testPact {
  typedef void (^CompleteBlock)();
  XCTestExpectation *exp = [self expectationWithDescription:@"Responds with hello"];

  MockService *mockService = [[MockService alloc] initWithProvider:@"Provider" consumer:@"consumer"];

  [[[mockService uponReceiving:@"a request for hello"]
                 withRequest:1 path:@"/sayHello" headers:nil body: nil]
                 willRespondWith:200 headers:@{@"Content-Type": @"application/json"} body: @"Hello" ];

  HelloClient *helloClient = [[HelloClient alloc] initWithBaseUrl:mockService.baseUrl];

  [mockService run:^(CompleteBlock complete) {
                     NSString *requestReply = [helloClient sayHello];
                     XCTAssertEqualObjects(requestReply, @"Hello");
                     complete();
                   }
                   result:^(PactVerificationResult result) {
                     XCTAssert(result == PactVerificationResultPassed);
                     [exp fulfill];
                   }];

  [self waitForExpectationsWithTimeout:5 handler:nil];
}
```
#### Objective-C Caveat: Your Test Target Must Include At Least One Swift File

The Swift stdlib will not be linked into your test target, and thus
PactConsumerSwift will fail to execute properly, if you test target does not contain
*at least one* Swift file. If it does not, your tests will exit
prematurely with the following error:

```
*** Test session exited(82) without checking in. Executable cannot be
loaded for some other reason, such as a problem with a library it
depends on or a code signature/entitlements mismatch.
```

To fix the problem, add a blank file called `PactFix.swift` to your test target:

```swift
// PactFix.swift

import PactConsumerSwift
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