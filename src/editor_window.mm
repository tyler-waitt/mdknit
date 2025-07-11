#import <Cocoa/Cocoa.h>
#include "text_buffer.h"
#import "outliner_protocol.h"
#import "outliner_view_controller.h"
#import "tree_outliner_view_controller.h"
#import "markdown_node.h"
#import "settings_manager.h"

@interface EditorWindowController : NSWindowController <NSTextViewDelegate, OutlinerDelegate, NSSplitViewDelegate>
@property (strong, nonatomic) NSTextView* textView;
@property (strong, nonatomic) NSSplitView* splitView;
@property (strong, nonatomic) NSViewController<OutlinerViewController>* outlinerController;
@property (nonatomic) TextBuffer textBuffer;
@property (strong, nonatomic) MarkdownNode* currentNode;
@property (strong, nonatomic) MarkdownNode* rootNode;
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
        
        [self setupUI];
        [self setupMenus];
        [self createSampleDocument];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(settingsChanged:)
                                                     name:kSettingsChangedNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    text_buffer_free(&_textBuffer);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupUI {
    self.splitView = [[NSSplitView alloc] initWithFrame:self.window.contentView.bounds];
    [self.splitView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [self.splitView setDividerStyle:NSSplitViewDividerStyleThin];
    [self.splitView setVertical:YES];
    [self.splitView setDelegate:self];
    
    [self createOutlinerForCurrentMode];
    
    NSScrollView* scrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, 500, 600)];
    [scrollView setHasVerticalScroller:YES];
    [scrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    
    self.textView = [[NSTextView alloc] initWithFrame:scrollView.bounds];
    [self.textView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [self.textView setDelegate:self];
    [self.textView setRichText:NO];
    [self.textView setAutomaticQuoteSubstitutionEnabled:NO];
    [self.textView setFont:[NSFont monospacedSystemFontOfSize:13.0 weight:NSFontWeightRegular]];
    
    [scrollView setDocumentView:self.textView];
    [self.splitView addSubview:scrollView];
    
    CGFloat initialOutlinerWidth = self.window.frame.size.width * 0.2;
    [self.splitView setPosition:initialOutlinerWidth ofDividerAtIndex:0];
    
    [self.window.contentView addSubview:self.splitView];
}

- (void)createOutlinerForCurrentMode {
    SettingsManager *settings = [SettingsManager sharedManager];
    
    if (settings.outlinerMode == OutlinerModeTree) {
        self.outlinerController = [[TreeOutlinerViewController alloc] init];
    } else {
        self.outlinerController = [[OutlinerViewController alloc] init];
    }
    
    self.outlinerController.delegate = self;
    [self.outlinerController.view setAutoresizingMask:NSViewHeightSizable];
    [self.splitView addSubview:self.outlinerController.view];
}

- (void)createSampleDocument {
    self.rootNode = [[MarkdownNode alloc] initWithTitle:@"Full Document" content:@""];
    
    MarkdownNode* intro = [[MarkdownNode alloc] initWithTitle:@"Introduction" 
                                                       content:@"Welcome to MDKnit, a visual markdown editor."];
    [self.rootNode addChild:intro];
    
    MarkdownNode* features = [[MarkdownNode alloc] initWithTitle:@"Features" content:@""];
    [self.rootNode addChild:features];
    
    MarkdownNode* dragDrop = [[MarkdownNode alloc] initWithTitle:@"Drag & Drop" 
                                                          content:@"Drag cards to reorder your document structure."];
    [features addChild:dragDrop];
    
    MarkdownNode* nesting = [[MarkdownNode alloc] initWithTitle:@"Nesting" 
                                                         content:@"Create hierarchical documents with nested sections."];
    [features addChild:nesting];
    
    MarkdownNode* usage = [[MarkdownNode alloc] initWithTitle:@"Usage" 
                                                       content:@"Click any card to edit its content in the editor."];
    [self.rootNode addChild:usage];
    
    self.outlinerController.rootNode = self.rootNode;
    [self.outlinerController reloadData];
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
    
    // Only update the node if it's a leaf node (no children)
    if (self.currentNode && self.currentNode.children.count == 0) {
        NSArray* lines = [content componentsSeparatedByString:@"\n"];
        if (lines.count > 0) {
            self.currentNode.title = lines[0];
            if (lines.count > 1) {
                NSMutableArray* contentLines = [lines mutableCopy];
                [contentLines removeObjectAtIndex:0];
                self.currentNode.content = [contentLines componentsJoinedByString:@"\n"];
            } else {
                self.currentNode.content = @"";
            }
        }
        [self.outlinerController reloadData];
    }
    // For parent nodes, the editor is read-only (showing aggregated content)
}

#pragma mark - OutlinerViewControllerDelegate

- (void)outlinerDidSelectNode:(MarkdownNode *)node {
    self.currentNode = node;
    
    // For parent nodes, show aggregated content of all children
    if (node.children.count > 0) {
        NSMutableString *aggregatedContent = [NSMutableString string];
        [self appendNodeContent:node toString:aggregatedContent withLevel:0];
        [self.textView setString:aggregatedContent];
        [self.textView setEditable:NO];
        [self.textView setBackgroundColor:[NSColor colorWithWhite:0.98 alpha:1.0]];
    } else {
        // For leaf nodes, show just the node's content
        NSString* fullContent = node.title;
        if (node.content.length > 0) {
            fullContent = [NSString stringWithFormat:@"%@\n%@", node.title, node.content];
        }
        [self.textView setString:fullContent];
        [self.textView setEditable:YES];
        [self.textView setBackgroundColor:[NSColor textBackgroundColor]];
    }
}

- (void)appendNodeContent:(MarkdownNode *)node toString:(NSMutableString *)string withLevel:(NSInteger)level {
    // Add the node's title as a heading
    for (NSInteger i = 0; i < level + 1; i++) {
        [string appendString:@"#"];
    }
    [string appendFormat:@" %@\n\n", node.title];
    
    // Add the node's content if it has any
    if (node.content.length > 0) {
        [string appendFormat:@"%@\n\n", node.content];
    }
    
    // Recursively add all children's content
    for (MarkdownNode *child in node.children) {
        [self appendNodeContent:child toString:string withLevel:level + 1];
    }
}

- (void)outlinerDidUpdateStructure {
    NSString* markdown = [self.rootNode generateMarkdown];
    const char* cString = [markdown UTF8String];
    text_buffer_set_text(&_textBuffer, cString, strlen(cString));
}

#pragma mark - Settings

- (void)settingsChanged:(NSNotification *)notification {
    [self switchOutliner];
}

- (void)switchOutliner {
    NSView *currentOutlinerView = self.outlinerController.view;
    CGFloat currentWidth = currentOutlinerView.frame.size.width;
    
    [currentOutlinerView removeFromSuperview];
    
    [self createOutlinerForCurrentMode];
    self.outlinerController.rootNode = self.rootNode;
    [self.outlinerController reloadData];
    
    if (self.currentNode) {
        [self.outlinerController selectNode:self.currentNode];
    }
    
    NSView *editorView = [self.splitView.subviews lastObject];
    [self.splitView setSubviews:@[self.outlinerController.view, editorView]];
    [self.splitView setPosition:currentWidth ofDividerAtIndex:0];
}

#pragma mark - NSSplitViewDelegate

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex {
    return 160.0;
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex {
    return splitView.frame.size.width * 0.45;
}

- (BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)view {
    if (view == self.outlinerController.view) {
        return NO;
    }
    return YES;
}

@end