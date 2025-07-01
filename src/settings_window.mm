#import "settings_window.h"
#import "settings_manager.h"

@interface SettingsWindowController ()
@property (nonatomic, strong) NSSegmentedControl *outlinerModeControl;
@end

@implementation SettingsWindowController

+ (instancetype)sharedController {
    static SettingsWindowController *sharedController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedController = [[self alloc] init];
    });
    return sharedController;
}

- (instancetype)init {
    NSRect frame = NSMakeRect(0, 0, 400, 200);
    NSUInteger styleMask = NSWindowStyleMaskTitled | NSWindowStyleMaskClosable;
    
    NSWindow *window = [[NSWindow alloc] initWithContentRect:frame
                                                   styleMask:styleMask
                                                     backing:NSBackingStoreBuffered
                                                       defer:NO];
    
    self = [super initWithWindow:window];
    if (self) {
        [window setTitle:@"MDKnit Preferences"];
        [window center];
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    NSView *contentView = self.window.contentView;
    
    NSTextField *label = [NSTextField labelWithString:@"Outliner Style:"];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:label];
    
    self.outlinerModeControl = [NSSegmentedControl segmentedControlWithLabels:@[@"Cards", @"Tree"]
                                                                  trackingMode:NSSegmentSwitchTrackingSelectOne
                                                                       target:self
                                                                       action:@selector(outlinerModeChanged:)];
    self.outlinerModeControl.translatesAutoresizingMaskIntoConstraints = NO;
    
    SettingsManager *settings = [SettingsManager sharedManager];
    self.outlinerModeControl.selectedSegment = settings.outlinerMode;
    
    [contentView addSubview:self.outlinerModeControl];
    
    NSTextField *descriptionLabel = [NSTextField wrappingLabelWithString:@"Cards: Visual card-based outline with drag and drop\nTree: Traditional macOS outline view"];
    descriptionLabel.font = [NSFont systemFontOfSize:11];
    descriptionLabel.textColor = [NSColor secondaryLabelColor];
    descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:descriptionLabel];
    
    [NSLayoutConstraint activateConstraints:@[
        [label.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:20],
        [label.topAnchor constraintEqualToAnchor:contentView.topAnchor constant:20],
        
        [self.outlinerModeControl.leadingAnchor constraintEqualToAnchor:label.trailingAnchor constant:10],
        [self.outlinerModeControl.centerYAnchor constraintEqualToAnchor:label.centerYAnchor],
        
        [descriptionLabel.leadingAnchor constraintEqualToAnchor:label.leadingAnchor],
        [descriptionLabel.topAnchor constraintEqualToAnchor:label.bottomAnchor constant:10],
        [descriptionLabel.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-20]
    ]];
}

- (void)outlinerModeChanged:(NSSegmentedControl *)sender {
    SettingsManager *settings = [SettingsManager sharedManager];
    settings.outlinerMode = (OutlinerMode)sender.selectedSegment;
}

- (void)showWindow {
    [self.window makeKeyAndOrderFront:nil];
}

@end