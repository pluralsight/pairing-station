@import QuartzCore;
#import "PRGUserView.h"
#import "PRGUser.h"
#import <AFNetworking/AFNetworking.h>
#import "NSImageView+AFNetworking.h"

@interface PRGUserView ()

@property (nonatomic, strong) IBOutlet NSTextField *nameLabel;

@property (nonatomic, strong) IBOutlet NSImageView *imageView;
@property (weak) IBOutlet NSButton *removeButton;

@end

static AFHTTPRequestOperationManager *requestManager;

@implementation PRGUserView

- (void)awakeFromNib {
    [self setWantsLayer:YES]; // required on NSView to use layer manipulation
    self.layer.backgroundColor = [NSColor whiteColor].CGColor;
    
    [self.nameLabel setStringValue:@"Come pair!"];
    [self.imageView setImage:nil];
}


- (void)viewDidMoveToWindow {
    [super viewDidMoveToWindow];
    self.imageView.layer.borderColor    = [NSColor lightGrayColor].CGColor;
    self.imageView.layer.cornerRadius   = 32;
    self.imageView.layer.borderWidth    = 1;
    self.imageView.layer.masksToBounds  = YES;
    
    self.layer.cornerRadius         = 5;
    self.layer.masksToBounds        = YES;
}


- (IBAction)userTappedChangeUser:(id)sender {
    if (self.changeUserHandler) {
        self.changeUserHandler();
    }
}

- (IBAction)removeUser:(id)sender {
    if (self.removeUserHandler) {
        self.removeUserHandler();
    }
}

- (IBAction)swapUsers:(id)sender {
    if (self.swapUsersHandler) {
        self.swapUsersHandler();
    }
}

- (void)setUser:(PRGUser *)user {
    _user = user;
    
    self.removeButton.hidden = user == nil;
    
    [self.nameLabel setStringValue:user ? user.displayName : @"Come pair!"];
    NSString *imageUrlPath = user.imageUrl ?: [user imageUrlPath];
    
    if (imageUrlPath) {
        [self.imageView setImageWithURL:[NSURL URLWithString:imageUrlPath]];
    } else {
        self.imageView.image = nil;
    }
}


+ (PRGUserView *)leftUserView {
    return [self userViewWithNibName:@"PRGUserViewLeft"];
}


+ (PRGUserView *)rightUserView {
    return [self userViewWithNibName:@"PRGUserViewRight"];
}


+ (PRGUserView *)userViewWithNibName:(NSString *)nibName {
    NSArray *arrayOfViews;
    [[NSBundle mainBundle] loadNibNamed:nibName owner:nil topLevelObjects:&arrayOfViews];
    
    for (id obj in arrayOfViews) {
        if ([obj isKindOfClass:[NSView class]]) {
            return obj;
        }
    }
    return nil;
}

@end
