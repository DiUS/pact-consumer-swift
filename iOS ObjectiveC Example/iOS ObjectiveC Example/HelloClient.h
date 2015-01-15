#import <Foundation/Foundation.h>

@interface HelloClient : NSObject
- (id)initWithBaseUrl:(NSString *)url;
- (NSString *)sayHello;
@end
