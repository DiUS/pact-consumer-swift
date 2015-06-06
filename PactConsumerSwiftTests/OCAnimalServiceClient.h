#import <Foundation/Foundation.h>

@interface Animal : NSObject
@property (nonatomic, strong) NSString* name;
@end

@interface OCAnimalServiceClient : NSObject
- (id)initWithBaseUrl:(NSString *)url;
- (Animal *)getAlligator;
- (NSArray *)findAnimalsLiving:(NSString *)living;
@end
