#import "PRGGitHubAPI.h"

@implementation PRGGitHubAPI

- (instancetype)init {
    self = [super init];
    if (self) {
        self.requestManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"https://api.github.com/"]];
        self.requestManager.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    return self;
}


- (void)fetchUserWithEmail:(NSString *)email
                  password:(NSString *)password
                completion:(PRGGitHubUserFetchCompletion)completion {
    [self.requestManager.requestSerializer setAuthorizationHeaderFieldWithUsername:email password:password];
    [self.requestManager GET:@"/user"
                  parameters:nil
                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                         if (completion) {
                             completion(responseObject);
                         }
                     }
                     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                         if (completion) {
                             completion(nil);
                         }
                     }];
}

@end
