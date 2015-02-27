

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "OCHelloClient.h"

@import PactConsumerSwift;

@interface PactTest : XCTestCase
@property (strong, nonatomic) MockService *mockService;
@property (strong, nonatomic) OCHelloClient *helloClient;
@end

@implementation PactTest

- (void)setUp {
  [super setUp];
  XCTestExpectation *exp = [self expectationWithDescription:@"Pacts all verified"];
  self.mockService = [[MockService alloc] initWithProvider:@"Hello Provider"
                                                  consumer:@"Hello Client Objective-C"
                                                      done:^(PactVerificationResult result) {
    XCTAssert(result == PactVerificationResultPassed);
    [exp fulfill];
  }];
  self.helloClient = [[OCHelloClient alloc] initWithBaseUrl:self.mockService.baseUrl];
}

- (void)tearDown {
  [super tearDown];
}

- (void)testPact {
  typedef void (^CompleteBlock)();
  [[[self.mockService uponReceiving:@"oc a request for hello"]
                      withRequest:PactHTTPMethodGet path:@"/sayHello" query:nil headers:nil body:nil]
                      willRespondWith:200 headers:@{@"Content-Type": @"application/json"} body: @"Hello" ];
  
  [self.mockService run:^(CompleteBlock testComplete) {
      NSString *requestReply = [self.helloClient sayHello];
      XCTAssertEqualObjects(requestReply, @"Hello");
      testComplete();
  } ];
  
  [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testWithQueryParams {
  typedef void (^CompleteBlock)();
  
  [[[self.mockService uponReceiving:@"oc a request friends"]
                      withRequest:PactHTTPMethodGet path:@"/friends" query: @{ @"age" : @"30", @"child" : @"Mary" } headers:nil body: nil]
                      willRespondWith:200 headers:@{@"Content-Type": @"application/json"} body: @{ @"friends": @[ @"Sue" ] } ];
  
  [self.mockService run:^(CompleteBlock testComplete) {
      NSString *response = [self.helloClient findFriendsByAgeAndChild];
      XCTAssertEqualObjects(response, @"{\"friends\":[\"Sue\"]}");
      testComplete();
  } ];
  
  [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testExpectedError {
  typedef void (^CompleteBlock)();
  
  [[[[self.mockService given: @"I have no friends" ]
                       uponReceiving:@"oc a request to unfriend"]
                       withRequest:PactHTTPMethodPut path:@"/unfriendMe" query: nil headers:nil body: nil]
                       willRespondWith:404 headers:nil body: nil ];
  
  [self.mockService run:^(CompleteBlock testComplete) {
    [self.helloClient unfriend:^(NSString *response) {
      XCTAssertFalse(true);
    } failure:^(NSInteger errorCode) {
      XCTAssertEqual(errorCode, 404);
    }];
    testComplete();
  } ];
  
  [self waitForExpectationsWithTimeout:5 handler:nil];
}

@end
