#import <Cocoa/Cocoa.h>
#include "text_buffer.h"

@interface EditorWindowController : NSWindowController <NSTextViewDelegate>
@property (strong, nonatomic) NSTextView* textView;
@property (nonatomic) TextBuffer textBuffer;
@end

@implementation EditorWindowController

- (instancetype)init {
    NSRect frame = NSMakeRect(0, 0, 800, 600);
    NSUInteger styleMask = NSWindowStyleMaskTitled | NSWindowStyleMaskClosable |
                           NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskResizable;
    
    NSWindow* window = [[NSWindow alloc] initWithContentRect:frame
                                                   styleMask:styleMask
                                                     backing:NSBackingStoreBuffered
                                                       defer:NO];
    
    self = [super initWithWindow:window];
    if (self) {
        [window setTitle:@"MDKnit"];
        [window center];
        
        text_buffer_init(&_textBuffer);
        
        [self setupTextView];
        [self setupMenus];
    }
    return self;
}

- (void)dealloc {
    text_buffer_free(&_textBuffer);
}

- (void)setupTextView {
    NSScrollView* scrollView = [[NSScrollView alloc] initWithFrame:self.window.contentView.bounds];
    [scrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [scrollView setHasVerticalScroller:YES];
    
    self.textView = [[NSTextView alloc] initWithFrame:scrollView.bounds];
    [self.textView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [self.textView setDelegate:self];
    [self.textView setRichText:NO];
    [self.textView setAutomaticQuoteSubstitutionEnabled:NO];
    [self.textView setFont:[NSFont monospacedSystemFontOfSize:13.0 weight:NSFontWeightRegular]];
    
    [scrollView setDocumentView:self.textView];
    [self.window.contentView addSubview:scrollView];
}

- (void)setupMenus {
    NSMenu* mainMenu = [NSApp mainMenu];
    
    NSMenuItem* fileMenuItem = [[NSMenuItem alloc] init];
    NSMenu* fileMenu = [[NSMenu alloc] initWithTitle:@"File"];
    [fileMenuItem setSubmenu:fileMenu];
    [mainMenu insertItem:fileMenuItem atIndex:1];
    
    NSMenuItem* newMenuItem = [[NSMenuItem alloc] initWithTitle:@"New"
                                                         action:@selector(newDocument:)
                                                  keyEquivalent:@"n"];
    [newMenuItem setTarget:self];
    [fileMenu addItem:newMenuItem];
    
    NSMenuItem* openMenuItem = [[NSMenuItem alloc] initWithTitle:@"Open..."
                                                          action:@selector(openDocument:)
                                                   keyEquivalent:@"o"];
    [openMenuItem setTarget:self];
    [fileMenu addItem:openMenuItem];
    
    NSMenuItem* saveMenuItem = [[NSMenuItem alloc] initWithTitle:@"Save"
                                                          action:@selector(saveDocument:)
                                                   keyEquivalent:@"s"];
    [saveMenuItem setTarget:self];
    [fileMenu addItem:saveMenuItem];
    
    NSMenuItem* saveAsMenuItem = [[NSMenuItem alloc] initWithTitle:@"Save As..."
                                                            action:@selector(saveDocumentAs:)
                                                     keyEquivalent:@"S"];
    [saveAsMenuItem setTarget:self];
    [fileMenu addItem:saveAsMenuItem];
}

#pragma mark - Actions

- (void)newDocument:(id)sender {
    text_buffer_clear(&_textBuffer);
    [self.textView setString:@""];
}

- (void)openDocument:(id)sender {
    NSOpenPanel* openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseFiles:YES];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setAllowsMultipleSelection:NO];
    
    [openPanel beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse result) {
        if (result == NSModalResponseOK) {
            NSURL* url = openPanel.URL;
            NSError* error;
            NSString* content = [NSString stringWithContentsOfURL:url
                                                         encoding:NSUTF8StringEncoding
                                                            error:&error];
            if (!error) {
                const char* cString = [content UTF8String];
                text_buffer_set_text(&self->_textBuffer, cString, strlen(cString));
                [self.textView setString:content];
            }
        }
    }];
}

- (void)saveDocument:(id)sender {
    [self saveDocumentAs:sender];
}

- (void)saveDocumentAs:(id)sender {
    NSSavePanel* savePanel = [NSSavePanel savePanel];
    [savePanel setAllowedFileTypes:@[@"md", @"txt"]];
    
    [savePanel beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse result) {
        if (result == NSModalResponseOK) {
            NSURL* url = savePanel.URL;
            NSString* content = [self.textView string];
            NSError* error;
            [content writeToURL:url
                     atomically:YES
                       encoding:NSUTF8StringEncoding
                          error:&error];
        }
    }];
}

#pragma mark - NSTextViewDelegate

- (void)textDidChange:(NSNotification*)notification {
    NSString* content = [self.textView string];
    const char* cString = [content UTF8String];
    text_buffer_set_text(&_textBuffer, cString, strlen(cString));
}

@end