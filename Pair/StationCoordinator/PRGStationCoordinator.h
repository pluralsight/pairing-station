@import AppKit;
@class PRGUserView, PRGUser, PRGGitManager, PRGGitHubAPI;

@interface PRGStationCoordinator : NSObject

@property (nonatomic, strong) PRGGitManager *gitManager;
@property (nonatomic, strong) PRGGitHubAPI *gitHubAPI;

@property (nonatomic, strong) PRGUser *leftUser;
@property (nonatomic, strong) PRGUser *rightUser;

@property (nonatomic, strong) NSWindow *overlayWindow;

@property (nonatomic, strong) PRGUserView *leftUserOverlay;
@property (nonatomic, strong) PRGUserView *rightUserOverlay;

@property (nonatomic, strong) NSTrackingArea *leftTrackingArea;
@property (nonatomic, strong) NSTrackingArea *rightTrackingArea;

- (void)initializePairingView;

- (void)showPairingOverlay;
- (void)hidePairingOverlay;

- (void)swapUsers;
- (void)removeLeftUser;
- (void)removeRightUser;
- (void)removeBoth;

@end
