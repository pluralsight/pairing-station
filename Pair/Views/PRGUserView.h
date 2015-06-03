#import <Cocoa/Cocoa.h>
@class PRGUser;
typedef void(^PRGUserViewTappedChangeHandler)();

@interface PRGUserView : NSView

@property (nonatomic, strong) PRGUser *user;

@property (nonatomic, copy) PRGUserViewTappedChangeHandler changeUserHandler;
@property (nonatomic, copy) PRGUserViewTappedChangeHandler removeUserHandler;
@property (nonatomic, copy) PRGUserViewTappedChangeHandler swapUsersHandler;

+ (PRGUserView *)leftUserView;
+ (PRGUserView *)rightUserView;

+ (PRGUserView *)userViewWithNibName:(NSString *)nibName;

@end
