#import "PRGGitManager.h"

@implementation PRGGitManager

- (void)setConfigUsername:(NSString *)name email:(NSString *)email {
    NSString *gitPath = @"/usr/bin/git";
    
    NSTask *nameTask = [[NSTask alloc] init];
    nameTask.launchPath = gitPath;
    nameTask.arguments = @[@"config", @"--global", @"user.name", name];
    [nameTask launch];
    
    [nameTask waitUntilExit];
    
    NSTask *emailTask = [NSTask new];
    emailTask.launchPath = gitPath;
    emailTask.arguments = @[@"config", @"--global", @"user.email", @""];
    [emailTask launch];
}

@end
