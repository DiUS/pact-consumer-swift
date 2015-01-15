
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
@end
