

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "OCAnimalServiceClient.h"

@import PactConsumerSwift;

@interface PactObjectiveCTests : XCTestCase
@property (strong, nonatomic) MockService *animalMockService;
@property (strong, nonatomic) OCAnimalServiceClient *animalServiceClient;
@end

@implementation PactObjectiveCTests

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

- (void)tearDown {
  [super tearDown];
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

- (void)testWithQueryParams {
  typedef void (^CompleteBlock)();
  
  [[[[self.animalMockService given:@"an alligator exists"]
                             uponReceiving:@"oc a request for animals living in water"]
                             withRequestHTTPMethod:PactHTTPMethodGET
                                              path:@"/animals"
                                             query: @{ @"live" : @"water" }
                                           headers:nil body: nil]
                             willRespondWithHTTPStatus:200
                                               headers:@{@"Content-Type": @"application/json"}
   body: @[ @{ @"name": [Matcher somethingLike:@"Mary"] } ] ];
  
  [self.animalMockService run:^(CompleteBlock testComplete) {
      NSArray *animals = [self.animalServiceClient findAnimalsLiving:@"water"];

      XCTAssertEqual(animals.count, 1);
      Animal *animal = animals[0];
      XCTAssertEqualObjects(animal.name, @"Mary");
      testComplete();
  }];
  
  [self waitForExpectationsWithTimeout:5 handler:nil];
}

@end
