@import QuartzCore;
#import "PRGUserView.h"
#import "PRGUser.h"
#import <AFNetworking/AFNetworking.h>
#import "NSImageView+AFNetworking.h"

@interface PRGUserView ()

@property (nonatomic, strong) IBOutlet NSTextField *nameLabel;

@property (nonatomic, strong) IBOutlet NSImageView *imageView;

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
    self.imageView.layer.cornerRadius   = 40;
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


- (void)setUser:(PRGUser *)user {
    _user = user;
    
    [self.nameLabel setStringValue:user.displayName];
    NSString *imageUrlPath = user.imageUrl ?: [user imageUrlPath];
    
    [self.imageView setImageWithURL:[NSURL URLWithString:imageUrlPath]];
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
