#import <Cocoa/Cocoa.h>

int main(int argc, const char* argv[]) {
    @autoreleasepool {
        NSApplication* app = [NSApplication sharedApplication];
        
        NSString* appName = @"MDKnit";
        NSMenu* menuBar = [[NSMenu alloc] init];
        
        NSMenuItem* appMenuItem = [[NSMenuItem alloc] init];
        [menuBar addItem:appMenuItem];
        
        NSMenu* appMenu = [[NSMenu alloc] init];
        [appMenuItem setSubmenu:appMenu];
        
        NSMenuItem* aboutMenuItem = [[NSMenuItem alloc] initWithTitle:[@"About " stringByAppendingString:appName]
                                                                action:@selector(orderFrontStandardAboutPanel:)
                                                         keyEquivalent:@""];
        [appMenu addItem:aboutMenuItem];
        
        [appMenu addItem:[NSMenuItem separatorItem]];
        
        NSMenuItem* preferencesMenuItem = [[NSMenuItem alloc] initWithTitle:@"Preferences..."
                                                                     action:@selector(showPreferences:)
                                                              keyEquivalent:@","];
        [appMenu addItem:preferencesMenuItem];
        
        [appMenu addItem:[NSMenuItem separatorItem]];
        
        NSMenuItem* quitMenuItem = [[NSMenuItem alloc] initWithTitle:[@"Quit " stringByAppendingString:appName]
                                                               action:@selector(terminate:)
                                                        keyEquivalent:@"q"];
        [appMenu addItem:quitMenuItem];
        
        [app setMainMenu:menuBar];
        
        id appDelegate = [[NSClassFromString(@"AppDelegate") alloc] init];
        [app setDelegate:appDelegate];
        
        [app run];
    }
    return 0;
}