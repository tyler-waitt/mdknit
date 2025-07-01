#import "node_card_view.h"

@interface NodeCardView ()
@property (nonatomic, strong) NSTextField *titleLabel;
@property (nonatomic, strong) NSButton *expandButton;
@property (nonatomic, strong) NSView *indentIndicator;
@property (nonatomic, strong) NSTrackingArea *trackingArea;
@property (nonatomic, assign) BOOL isHovered;
@end

@implementation NodeCardView

- (instancetype)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.wantsLayer = YES;
    self.layer.cornerRadius = 6;
    self.layer.shadowColor = [NSColor.blackColor CGColor];
    self.layer.shadowOffset = CGSizeMake(0, 1);
    self.layer.shadowRadius = 2;
    self.layer.shadowOpacity = 0.05;
    self.layer.borderWidth = 1;
    self.layer.borderColor = [[NSColor separatorColor] CGColor];
    
    self.expandButton = [NSButton buttonWithImage:[NSImage imageNamed:NSImageNameRightFacingTriangleTemplate] 
                                           target:self 
                                           action:@selector(toggleExpansion:)];
    self.expandButton.bordered = NO;
    self.expandButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.expandButton.imageScaling = NSImageScaleProportionallyDown;
    self.expandButton.contentTintColor = [NSColor secondaryLabelColor];
    [self addSubview:self.expandButton];
    
    self.titleLabel = [NSTextField labelWithString:@""];
    self.titleLabel.font = [NSFont systemFontOfSize:13 weight:NSFontWeightRegular];
    self.titleLabel.textColor = NSColor.labelColor;
    self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.titleLabel];
    
    NSLayoutConstraint *leadingConstraint = [self.expandButton.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:8];
    self.indentIndicator = (NSView *)leadingConstraint;
    
    [NSLayoutConstraint activateConstraints:@[
        leadingConstraint,
        [self.expandButton.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
        [self.expandButton.widthAnchor constraintEqualToConstant:16],
        [self.expandButton.heightAnchor constraintEqualToConstant:16],
        
        [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.expandButton.trailingAnchor constant:4],
        [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-12],
        [self.titleLabel.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
        
        [self.heightAnchor constraintEqualToConstant:36]
    ]];
}

- (void)updateWithNode:(MarkdownNode *)node {
    self.node = node;
    self.titleLabel.stringValue = node.title;
    
    NSLayoutConstraint *leadingConstraint = (NSLayoutConstraint *)self.indentIndicator;
    leadingConstraint.constant = 8 + (node.nestingLevel * 20);
    
    if (node.children.count > 0) {
        self.expandButton.hidden = NO;
        CGFloat rotation = node.isExpanded ? 90.0 : 0.0;
        self.expandButton.frameCenterRotation = rotation;
    } else {
        self.expandButton.hidden = YES;
    }
    
    [self updateAppearance];
}

- (void)updateAppearance {
    if (self.isSelected) {
        self.layer.backgroundColor = [[NSColor selectedContentBackgroundColor] colorWithAlphaComponent:0.1].CGColor;
        self.layer.borderColor = [[NSColor controlAccentColor] CGColor];
    } else if (self.isHovered) {
        self.layer.backgroundColor = [[NSColor labelColor] colorWithAlphaComponent:0.05].CGColor;
    } else {
        self.layer.backgroundColor = [NSColor.controlBackgroundColor CGColor];
        self.layer.borderColor = [[NSColor separatorColor] CGColor];
    }
}

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    [self updateAppearance];
}

- (void)toggleExpansion:(id)sender {
    [self.delegate nodeCardViewDidToggleExpansion:self];
}

- (void)mouseDown:(NSEvent *)event {
    [self.delegate nodeCardViewDidRequestEdit:self];
}

- (void)updateTrackingAreas {
    [super updateTrackingAreas];
    
    if (self.trackingArea) {
        [self removeTrackingArea:self.trackingArea];
    }
    
    self.trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds
                                                      options:NSTrackingMouseEnteredAndExited | NSTrackingActiveInKeyWindow
                                                        owner:self
                                                     userInfo:nil];
    [self addTrackingArea:self.trackingArea];
}

- (void)mouseEntered:(NSEvent *)event {
    self.isHovered = YES;
    [self updateAppearance];
}

- (void)mouseExited:(NSEvent *)event {
    self.isHovered = NO;
    [self updateAppearance];
}

@end

@implementation NodeCollectionViewItem

- (void)loadView {
    self.cardView = [[NodeCardView alloc] initWithFrame:NSMakeRect(0, 0, 300, 44)];
    self.view = self.cardView;
}

@end