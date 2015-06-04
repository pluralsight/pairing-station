#import "StatusItemView.h"

@interface StatusItemView()

@property (nonatomic, readonly) NSMenu *menu;

@end

@implementation StatusItemView

@synthesize statusItem = _statusItem;
@synthesize image = _image;
@synthesize alternateImage = _alternateImage;
@synthesize isHighlighted = _isHighlighted;
@synthesize action = _action;
@synthesize target = _target;
@synthesize menu = _menu;

#pragma mark -

- (id)initWithStatusItem:(NSStatusItem *)statusItem
{
    CGFloat itemWidth = [statusItem length];
    CGFloat itemHeight = [[NSStatusBar systemStatusBar] thickness];
    NSRect itemRect = NSMakeRect(0.0, 0.0, itemWidth, itemHeight);
    self = [super initWithFrame:itemRect];
    
    if (self != nil) {
        _statusItem = statusItem;
        _statusItem.view = self;
        [_statusItem setMenu:[self menu]];
    }
    return self;
}

- (NSMenu *)menu
{
    if (!_menu) {
        _menu = [[NSMenu alloc] init];
        NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"Quit Pair" action:@selector(test) keyEquivalent:@""];
        menuItem.target = self;
        [_menu addItem:menuItem];
    }
    
    return _menu;
}

- (void)test
{
    NSLog(@"");
}


#pragma mark -

- (void)drawRect:(NSRect)dirtyRect
{
	// Set up dark mode for icon
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"AppleInterfaceStyle"]  isEqual: @"Dark"])
    {
        self.image = [NSImage imageNamed:@"menubar-icon"];
    }
    else
    {
        if (self.isHighlighted)
            self.image = [NSImage imageNamed:@"menubar-icon"];
        else
            self.image = [NSImage imageNamed:@"menubar-icon"];
    }
	[self.statusItem drawStatusBarBackgroundInRect:dirtyRect withHighlight:self.isHighlighted];
    
    NSImage *icon = self.image;
    NSSize iconSize = [icon size];
    NSRect bounds = self.bounds;
    CGFloat iconX = roundf((NSWidth(bounds) - iconSize.width) / 2);
    CGFloat iconY = roundf((NSHeight(bounds) - iconSize.height) / 2);
    NSPoint iconPoint = NSMakePoint(iconX, iconY);

	[icon drawAtPoint:iconPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
}

#pragma mark -
#pragma mark Mouse tracking
//
//- (void)mouseDown:(NSEvent *)theEvent
//{
//    [NSApp sendAction:self.action to:self.target from:self];
//}

#pragma mark -
#pragma mark Accessors

- (void)setHighlighted:(BOOL)newFlag
{
    if (_isHighlighted == newFlag) return;
    _isHighlighted = newFlag;
    [self setNeedsDisplay:YES];
}

#pragma mark -

- (void)setImage:(NSImage *)newImage
{
    if (_image != newImage) {
        _image = newImage;
        [self setNeedsDisplay:YES];
    }
}

- (void)setAlternateImage:(NSImage *)newImage
{
    if (_alternateImage != newImage) {
        _alternateImage = newImage;
        if (self.isHighlighted) {
            [self setNeedsDisplay:YES];
        }
    }
}

#pragma mark -

- (NSRect)globalRect
{
    NSRect frame = [self frame];
    return [self.window convertRectToScreen:frame];
}
@end
