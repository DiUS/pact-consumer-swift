#import <Foundation/Foundation.h>

@interface HelloClient : NSObject
- (id)initWithBaseUrl:(NSString *)url;
- (NSString *)sayHello;

- (NSString *)findFriendsByAgeAndChild;
- (void) unfriend:(void (^)(NSString *response))success failure:(void (^)(NSInteger errorCode))failure;
@end
