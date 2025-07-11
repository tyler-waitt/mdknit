#import <Cocoa/Cocoa.h>
#import "settings_window.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property (strong, nonatomic) NSWindowController* mainWindowController;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification*)notification {
    Class editorWindowClass = NSClassFromString(@"EditorWindowController");
    self.mainWindowController = [[editorWindowClass alloc] init];
    [self.mainWindowController showWindow:nil];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication*)sender {
    return YES;
}

- (void)showPreferences:(id)sender {
    [[SettingsWindowController sharedController] showWindow];
}

@end