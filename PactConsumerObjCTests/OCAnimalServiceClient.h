#import <Foundation/Foundation.h>

@interface Animal : NSObject
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* dob;
@property (nonatomic, strong) NSNumber* legs;
@end

@interface OCAnimalServiceClient : NSObject <NSURLSessionDataDelegate>
- (id)initWithBaseUrl:(NSString *)url;
- (Animal *)getAlligator;
- (NSArray *)findAnimalsLiving:(NSString *)living;
@end
