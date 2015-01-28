
#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#include "HelloClient.h"
@import PactConsumerSwift;
@import UIKit;

@interface PactTest : XCTestCase
@end

@implementation PactTest

- (void)setUp {
  [super setUp];

}

- (void)tearDown {
  [super tearDown];
}

- (void)testPact {
  typedef void (^CompleteBlock)();
  XCTestExpectation *exp = [self expectationWithDescription:@"Responds with hello"];
  
  MockService *mockService = [[MockService alloc] initWithProvider:@"Provider" consumer:@"consumer"];
  
  [[[mockService uponReceiving:@"a request for hello"]
                 withRequest:1 path:@"/sayHello" query:nil headers:nil body: nil]
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

- (void)testWithQueryParams {
  typedef void (^CompleteBlock)();
  XCTestExpectation *exp = [self expectationWithDescription:@"Responds with matching friends"];
  
  MockService *mockService = [[MockService alloc] initWithProvider:@"Hello Provider" consumer:@"Hello consumer"];
  
  [[[mockService uponReceiving:@"a request friends"]
    withRequest:1 path:@"/friends" query: @{ @"age" : @"30", @"child" : @"Mary" } headers:nil body: nil]
   willRespondWith:200 headers:@{@"Content-Type": @"application/json"} body: @{ @"friends": @[ @"Sue" ] } ];
  
  HelloClient *helloClient = [[HelloClient alloc] initWithBaseUrl:mockService.baseUrl];
  
  [mockService run:^(CompleteBlock complete) {
    NSString *response = [helloClient findFriendsByAgeAndChild];
    XCTAssertEqualObjects(response, @"{\"friends\":[\"Sue\"]}");
    complete();
  }
            result:^(PactVerificationResult result) {
              XCTAssert(result == PactVerificationResultPassed);
              [exp fulfill];
            }];
  
  [self waitForExpectationsWithTimeout:5 handler:nil];
}

@end