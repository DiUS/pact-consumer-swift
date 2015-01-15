
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

@end