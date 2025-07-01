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