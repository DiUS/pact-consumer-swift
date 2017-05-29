
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
  
  NSData *response = [self sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
  
  
  
  NSError *error;
  NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:response
                                                      options:kNilOptions
                                                        error:&error];

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

  NSData *response = [self sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];

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

- (NSData *)sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSURLResponse **)response error:(NSError **)error {
  
  NSError __block *err = NULL;
  NSData __block *data;
  BOOL __block reqProcessed = false;
  NSURLResponse __block *resp;
  NSURLSession * sess = [NSURLSession sharedSession];
  
  [[sess dataTaskWithRequest:request
           completionHandler:^(NSData * _Nullable _data, NSURLResponse * _Nullable _resp, NSError * _Nullable _err) {
             resp = _resp;
             err = _err;
             data = _data;
             reqProcessed = true;
           }] resume];
  
  while (!reqProcessed) { [NSThread sleepForTimeInterval: 0]; }
  
  *response = resp;
  *error = err;
  return data;
}

@end
