
#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
@import PactConsumerSwift;
//#import <PactConsumerSwift/PactConsumerSwift.h>
@import UIKit;
//#import <PactConsumerSwift/>

@interface iOS_ObjectiveC_ExampleTests : XCTestCase
@property(nonatomic, strong) MockService *mockService;
@end

@implementation iOS_ObjectiveC_ExampleTests

- (void)setUp {
  [super setUp];
  self.mockService = [[MockService alloc] initWithProvider:@"Provider" consumer:@"consumer"];
  
  [[[self.mockService uponReceiving:@"a request for hello"]
    withRequest:1 path:@"/sayHello" headers:nil body: nil]
   willRespondWith:200 headers:@{@"Content-Type": @"application/json"} body: @"Hello" ];
}

- (void)tearDown {
  [super tearDown];
}

- (void)testExample {
  // This is an example of a functional test case.
  XCTAssert(YES, @"Pass");
  typedef void (^CompleteBlock)();
  //Run the tests
  XCTestExpectation *exp = [self expectationWithDescription:@"Responds with hello"];
  
  [self.mockService run:^(CompleteBlock complete)
   {
     NSString* url = [NSString stringWithFormat:@"%@/%@", self.mockService.baseUrl, @"sayHello"];
     NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                            cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                        timeoutInterval:10];
     
     [request setHTTPMethod: @"GET"];
     NSError *requestError;
     NSURLResponse *urlResponse = nil;
     
     NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
     
     NSString *requestReply = [[NSString alloc] initWithBytes:[response bytes] length:[response length] encoding:NSASCIIStringEncoding];
     NSLog(@"requestReply: %@", requestReply);
     XCTAssertEqualObjects(requestReply, @"Hello");
     
     complete();
   }
                 result:^(PactVerificationResult result)
   {
     XCTAssert(result == PactVerificationResultPassed);
     [exp fulfill];
   }];
  
  [self waitForExpectationsWithTimeout:5 handler:nil];
}

@end