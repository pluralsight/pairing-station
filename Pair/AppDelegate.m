#import "AppDelegate.h"
#import "PRGStationCoordinator.h"
#import "PRGUser.h"
@import AppKit;
#import "MenubarController.h"

@interface AppDelegate ()

@property (nonatomic, strong) PRGStationCoordinator *stationCoordinator;
@property (nonatomic, strong) MenubarController *menuController;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.menuController = [MenubarController new];
    
    self.stationCoordinator = [[PRGStationCoordinator alloc] init];
    [self.stationCoordinator initializePairingView];
    
    [self.stationCoordinator showPairingOverlay];
    [self configureToShowOnUnlock];
}


- (void)configureToShowOnUnlock {
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                        selector:@selector(screenUnlocked:)
                                                            name:@"com.apple.sessionAgent.SessionSwitchReady"
                                                          object:nil];
}


- (void)screenUnlocked:(NSNotification *)notif {
    [self.stationCoordinator showPairingOverlay];
}

- (void)quit {
    [NSApp terminate:self];
}

- (void)swap {
    [self.stationCoordinator swapUsers];
}

- (void)removeLeft
{
    [self.stationCoordinator removeLeftUser];
}

- (void)removeRight
{
    [self.stationCoordinator removeRightUser];
}

- (void)removeBoth
{
    [self.stationCoordinator removeBoth];
}


@end
