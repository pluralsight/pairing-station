#import "PRGStationCoordinator.h"
#import "PRGUserView.h"
#import "PRGUser.h"
#import "PRGGitManager.h"
#import "PRGGitHubAPI.h"

typedef NS_ENUM(NSInteger, PRGSeatSide) {
    PRGSeatSideLeft,
    PRGSeatSideRight
};

@implementation PRGStationCoordinator

BOOL waitingToShowOverlay = NO;
BOOL shouldLockOverlayOn  = NO;

- (instancetype)init {
    self = [super init];
    if (self) {
        _gitManager = [[PRGGitManager alloc] init];
        _gitHubAPI  = [[PRGGitHubAPI alloc] init];
    }
    return self;
}

- (void)initializePairingView {
    NSScreen *mainScreen    = [NSScreen mainScreen];
    NSRect mainScreenBounds = mainScreen.frame;
    
    NSInteger overlayWidth   = 300;
    NSInteger overlayHeight  = 100;
    
    NSRect overlayBoundingRect = NSMakeRect(0, mainScreenBounds.size.height - 70, mainScreenBounds.size.width, overlayHeight);
    self.overlayWindow = [[NSWindow alloc] initWithContentRect:overlayBoundingRect
                                                     styleMask:NSBorderlessWindowMask
                                                       backing:NSBackingStoreBuffered
                                                         defer:YES];
    [self.overlayWindow setOpaque:NO];
    [self.overlayWindow setBackgroundColor:[NSColor clearColor]];
    [self.overlayWindow setAlphaValue:0];
    [self.overlayWindow setHasShadow:NO];
    [self.overlayWindow setLevel:NSFloatingWindowLevel];
    [self.overlayWindow setIgnoresMouseEvents:YES];
    [self.overlayWindow orderFront:self];
    
    [[self.overlayWindow contentView] layer].backgroundColor = [NSColor colorWithWhite:0 alpha:0.0].CGColor;
    [self.overlayWindow makeKeyAndOrderFront:self];
    
    self.leftTrackingArea = [[NSTrackingArea alloc] initWithRect:NSMakeRect(0, 0, overlayWidth, overlayHeight)
                                                         options:NSTrackingMouseEnteredAndExited|NSTrackingActiveAlways
                                                           owner:self
                                                        userInfo:nil];
    
    [[self.overlayWindow contentView] addTrackingArea:self.leftTrackingArea];
    self.rightTrackingArea = [[NSTrackingArea alloc] initWithRect:NSMakeRect(mainScreenBounds.size.width - overlayWidth,
                                                                             0,
                                                                             overlayWidth,
                                                                             overlayHeight)
                                                          options:NSTrackingMouseEnteredAndExited|NSTrackingActiveAlways
                                                            owner:self
                                                         userInfo:nil];
    
    [[self.overlayWindow contentView] addTrackingArea:self.rightTrackingArea];
    
    __weak PRGStationCoordinator *weakSelf = self;
    
    self.leftUserOverlay = [PRGUserView leftUserView];
    [self.leftUserOverlay setChangeUserHandler:^{
        [weakSelf promptForLoginOnSeatSide:PRGSeatSideLeft];
    }];
    [self.overlayWindow.contentView addSubview:self.leftUserOverlay];
    
    self.rightUserOverlay = [PRGUserView rightUserView];
    [self.rightUserOverlay setChangeUserHandler:^{
        [weakSelf promptForLoginOnSeatSide:PRGSeatSideRight];
    }];
    [self.overlayWindow.contentView addSubview:self.rightUserOverlay];
    self.rightUserOverlay.frame = NSMakeRect(mainScreenBounds.size.width - overlayWidth, 0, overlayWidth, 110);
    
    [self applyUsersToGitProfile];
}


- (void)promptForLoginOnSeatSide:(PRGSeatSide)seatSide {
    shouldLockOverlayOn = YES;
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Enter your Github username"];
    [alert addButtonWithTitle:@"Ok"];
    [alert addButtonWithTitle:@"Cancel"];
    
    NSString *username;
    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
    [input setStringValue:@""];
    
    [alert setAccessoryView:input];
    NSInteger button = [alert runModal];
    if (button == NSAlertFirstButtonReturn) {
        username = [input stringValue];
    }
    
    [self.gitHubAPI fetchUserWithName:username
                           completion:^(NSDictionary *userDict) {
                               if (!userDict || (!userDict[@"login"] && !userDict[@"name"])) {
                                   shouldLockOverlayOn = NO;
                                   return;
                               }
                               PRGUser *user = [[PRGUser alloc] init];
                               user.name = userDict[@"name"];
                               user.username        = username;
                               user.email       = userDict[@"email"];
                               user.imageUrl    = userDict[@"avatar_url"];
                               
                               if (seatSide == PRGSeatSideLeft) {
                                   [self setLeftUser:user];
                               }
                               else {
                                   [self setRightUser:user];
                               }
                               shouldLockOverlayOn = NO;
                           }];
}


- (void)mouseEntered:(NSEvent *)theEvent {
    waitingToShowOverlay = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!waitingToShowOverlay) {
            return;
        }
        [self showPairingOverlay];
    });
    
}


- (void)mouseExited:(NSEvent *)theEvent {
    waitingToShowOverlay = NO;
    if (shouldLockOverlayOn) {
        return;
    }
    [self hidePairingOverlay];
}


- (void)showPairingOverlay {
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        [[self.overlayWindow animator] setAlphaValue:1.0];
        [self.overlayWindow setIgnoresMouseEvents:NO];
        
    } completionHandler:^{
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    }];
}


- (void)hidePairingOverlay {
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        
        [[self.overlayWindow animator] setAlphaValue:0];
        [self.overlayWindow setIgnoresMouseEvents:YES];
        
    } completionHandler:^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
    }];
}


- (void)setLeftUser:(PRGUser *)user {
    _leftUser = user;
    [self.leftUserOverlay setUser:user];
    [self applyUsersToGitProfile];
}


- (void)setRightUser:(PRGUser *)user {
    _rightUser = user;
    [self.rightUserOverlay setUser:user];
    [self applyUsersToGitProfile];
}


- (NSString *)emailString {
    NSString *emailString;
    if (!_leftUser.email && !_rightUser.email) {
        emailString = nil;
    }
    else if (_leftUser.email && _rightUser.email) {
        emailString = [NSString stringWithFormat:@"%@, %@", _leftUser.email, _rightUser.email];
    }
    else {
        emailString = _leftUser.email ?: _rightUser.email;
    }
    return emailString;
}

- (NSString *)nameString {
    NSString *nameString;
    if (!_leftUser.displayName && !_rightUser.displayName) {
        nameString = @"Pairing Station";
    }
    else if (_leftUser.displayName && _rightUser.displayName) {
        nameString = [NSString stringWithFormat:@"%@ and %@", _leftUser.displayName, _rightUser.displayName];
    }
    else {
        nameString = _leftUser.displayName ?: _rightUser.displayName;
    }
    return nameString;
}

- (void)applyUsersToGitProfile {
    NSString *nameString = [self nameString];
    NSString *emailString = [self emailString];
    [self.gitManager setConfigUsername:nameString email:emailString];
}

@end
