
#import "OCAnimalServiceClient.h"

@implementation Animal

@end

@interface OCAnimalServiceClient ()
@property (nonatomic, strong) NSString *baseUrl;
@end

@implementation OCAnimalServiceClient

- (id)initWithBaseUrl:(NSString *)url {
  if (self = [super init]) {
    self.baseUrl = url;
  }
  return self;
}

- (Animal *)getAlligator {
  NSString *url = [NSString stringWithFormat:@"%@/%@", self.baseUrl, @"alligator"];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                         cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                     timeoutInterval:10];
  
  [request setHTTPMethod: @"GET"];
  NSError *requestError;
  NSURLResponse *urlResponse = nil;
  
  NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];

  NSError *error;
  NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&error];

  Animal * animal = [[Animal alloc] init];
  animal.name = dic[@"name"];
  animal.dob = dic[@"dateOfBirth"];
  animal.legs = dic[@"legs"];
  
  return animal;
}

- (NSArray *)findAnimalsLiving:(NSString *)living {
  NSString *query = [NSString stringWithFormat:@"animals?live=%@", living];
  NSString *url = [NSString stringWithFormat:@"%@/%@", self.baseUrl, query];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                         cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                     timeoutInterval:10];

  [request setHTTPMethod: @"GET"];
  NSError *requestError;
  NSURLResponse *urlResponse = nil;

  NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];

  NSError *error;
  NSArray *array = [NSJSONSerialization JSONObjectWithData:response options:kNilOptions error:&error];

  NSMutableArray *animals = [[NSMutableArray alloc] init];

  for(NSDictionary *dic in array) {
    Animal * animal = [[Animal alloc] init];
    animal.name = dic[@"name"];
    animal.legs = dic[@"legs"];
    [animals addObject:animal];
  }

  return animals;
}

@end
