
#import "HelloClient.h"

@interface HelloClient()
@property (nonatomic, strong) NSString *baseUrl;
@end

@implementation HelloClient

- (id)initWithBaseUrl:(NSString *)url {
  if (self = [super init]) {
    self.baseUrl = url;
  }
  return self;
}

- (NSString *)sayHello {
  NSString *url = [NSString stringWithFormat:@"%@/%@", self.baseUrl, @"sayHello"];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                         cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                     timeoutInterval:10];
  
  [request setHTTPMethod: @"GET"];
  NSError *requestError;
  NSURLResponse *urlResponse = nil;
  
  NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
  
  NSString *requestReply = [[NSString alloc] initWithBytes:[response bytes] length:[response length] encoding:NSASCIIStringEncoding];
  NSLog(@"requestReply: %@", requestReply);
  
  return requestReply;
}

- (NSString *)findFriendsByAgeAndChild {
  NSString *url = [NSString stringWithFormat:@"%@/%@", self.baseUrl, @"friends?age=30&child=Mary"];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                         cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                     timeoutInterval:10];
  
  [request setHTTPMethod: @"GET"];
  NSError *requestError;
  NSURLResponse *urlResponse = nil;
  
  NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
  
  NSString *requestReply = [[NSString alloc] initWithBytes:[response bytes] length:[response length] encoding:NSASCIIStringEncoding];
  NSLog(@"requestReply: %@", requestReply);
  
  return requestReply;
}

- (void) unfriend:(void (^)(NSString *response))success failure:(void (^)(NSInteger errorCode))failure {
  NSString *url = [NSString stringWithFormat:@"%@/%@", self.baseUrl, @"unfriendMe"];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                         cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                     timeoutInterval:10];
  
  [request setHTTPMethod: @"PUT"];
  NSError *requestError;
  NSHTTPURLResponse *urlResponse = nil;
  
  NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
  
  if(urlResponse.statusCode > 299) {
    failure(urlResponse.statusCode);
  } else {
    NSString *requestReply = [[NSString alloc] initWithBytes:[response bytes] length:[response length] encoding:NSASCIIStringEncoding];
    NSLog(@"requestReply: %@", requestReply);
    success(requestReply);
  }
}

@end
