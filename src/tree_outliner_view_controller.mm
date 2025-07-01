#import "tree_outliner_view_controller.h"

static NSString *const kNodeCellIdentifier = @"NodeCell";
static NSString *const kNodePasteboardType = @"com.mdknit.treenode";

@interface TreeOutlinerViewController ()
@property (nonatomic, strong) NSOutlineView *outlineView;
@property (nonatomic, strong) NSScrollView *scrollView;
@property (nonatomic, strong) NSTreeController *treeController;
@end

@implementation TreeOutlinerViewController

- (void)loadView {
    self.view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 300, 600)];
    
    self.outlineView = [[NSOutlineView alloc] init];
    self.outlineView.dataSource = self;
    self.outlineView.delegate = self;
    self.outlineView.headerView = nil;
    self.outlineView.rowHeight = 28;
    self.outlineView.indentationPerLevel = 16;
    self.outlineView.autoresizesOutlineColumn = YES;
    self.outlineView.floatsGroupRows = NO;
    self.outlineView.rowSizeStyle = NSTableViewRowSizeStyleDefault;
    self.outlineView.focusRingType = NSFocusRingTypeNone;
    self.outlineView.allowsMultipleSelection = NO;
    
    NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:@"TitleColumn"];
    column.editable = NO;
    column.minWidth = 100;
    [self.outlineView addTableColumn:column];
    [self.outlineView setOutlineTableColumn:column];
    
    [self.outlineView registerForDraggedTypes:@[kNodePasteboardType]];
    [self.outlineView setDraggingSourceOperationMask:NSDragOperationMove forLocal:YES];
    
    self.scrollView = [[NSScrollView alloc] init];
    self.scrollView.documentView = self.outlineView;
    self.scrollView.hasVerticalScroller = YES;
    self.scrollView.autohidesScrollers = YES;
    self.scrollView.borderType = NSNoBorder;
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:self.scrollView];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.scrollView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.rootNode) {
        self.rootNode = [[MarkdownNode alloc] initWithTitle:@"Document" content:@""];
    }
}

- (void)reloadData {
    [self.outlineView reloadData];
    [self expandAllItems];
}

- (void)expandAllItems {
    for (MarkdownNode *child in self.rootNode.children) {
        [self expandNode:child];
    }
}

- (void)expandNode:(MarkdownNode *)node {
    if (node.isExpanded) {
        [self.outlineView expandItem:node];
        for (MarkdownNode *child in node.children) {
            [self expandNode:child];
        }
    }
}

- (void)selectNode:(MarkdownNode *)node {
    NSInteger row = [self.outlineView rowForItem:node];
    if (row >= 0) {
        [self.outlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
        [self.outlineView scrollRowToVisible:row];
    }
}

#pragma mark - NSOutlineViewDataSource

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    if (!item) {
        return 1;  // Just the root node
    }
    MarkdownNode *node = item;
    return node.children.count;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    if (!item) {
        return self.rootNode;  // Return the root node itself
    }
    MarkdownNode *node = item;
    return node.children[index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    MarkdownNode *node = item;
    return node.children.count > 0;
}

#pragma mark - NSOutlineViewDelegate

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    NSTableCellView *cellView = [outlineView makeViewWithIdentifier:kNodeCellIdentifier owner:self];
    
    if (!cellView) {
        cellView = [[NSTableCellView alloc] init];
        cellView.identifier = kNodeCellIdentifier;
        
        NSTextField *textField = [NSTextField labelWithString:@""];
        textField.font = [NSFont systemFontOfSize:13];
        textField.lineBreakMode = NSLineBreakByTruncatingTail;
        textField.translatesAutoresizingMaskIntoConstraints = NO;
        
        cellView.textField = textField;
        [cellView addSubview:textField];
        
        [NSLayoutConstraint activateConstraints:@[
            [textField.leadingAnchor constraintEqualToAnchor:cellView.leadingAnchor constant:2],
            [textField.trailingAnchor constraintEqualToAnchor:cellView.trailingAnchor constant:-2],
            [textField.centerYAnchor constraintEqualToAnchor:cellView.centerYAnchor]
        ]];
    }
    
    MarkdownNode *node = item;
    cellView.textField.stringValue = node.title;
    
    return cellView;
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
    NSInteger selectedRow = self.outlineView.selectedRow;
    if (selectedRow >= 0) {
        MarkdownNode *node = [self.outlineView itemAtRow:selectedRow];
        [self.delegate outlinerDidSelectNode:node];
    }
}

- (void)outlineViewItemDidExpand:(NSNotification *)notification {
    MarkdownNode *node = notification.userInfo[@"NSObject"];
    node.isExpanded = YES;
}

- (void)outlineViewItemDidCollapse:(NSNotification *)notification {
    MarkdownNode *node = notification.userInfo[@"NSObject"];
    node.isExpanded = NO;
}

#pragma mark - Drag and Drop

- (BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pasteboard {
    if (items.count != 1) return NO;
    
    MarkdownNode *node = items[0];
    [pasteboard declareTypes:@[kNodePasteboardType] owner:self];
    [pasteboard setString:node.nodeId forType:kNodePasteboardType];
    return YES;
}

- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id<NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(NSInteger)index {
    NSPasteboard *pb = [info draggingPasteboard];
    if (![pb canReadItemWithDataConformingToTypes:@[kNodePasteboardType]]) {
        return NSDragOperationNone;
    }
    
    NSString *nodeId = [pb stringForType:kNodePasteboardType];
    MarkdownNode *draggedNode = [self findNodeWithId:nodeId inNode:self.rootNode];
    
    if (!draggedNode) return NSDragOperationNone;
    
    MarkdownNode *targetParent = item ?: self.rootNode;
    if ([self isNode:targetParent descendantOf:draggedNode]) {
        return NSDragOperationNone;
    }
    
    return NSDragOperationMove;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id<NSDraggingInfo>)info item:(id)item childIndex:(NSInteger)index {
    NSPasteboard *pb = [info draggingPasteboard];
    NSString *nodeId = [pb stringForType:kNodePasteboardType];
    
    MarkdownNode *draggedNode = [self findNodeWithId:nodeId inNode:self.rootNode];
    if (!draggedNode) return NO;
    
    [draggedNode.parent removeChild:draggedNode];
    
    MarkdownNode *targetParent = item ?: self.rootNode;
    if (index == NSOutlineViewDropOnItemIndex) {
        [targetParent addChild:draggedNode];
    } else {
        [targetParent insertChild:draggedNode atIndex:index];
    }
    
    [self reloadData];
    [self.delegate outlinerDidUpdateStructure];
    
    return YES;
}

#pragma mark - Helper Methods

- (MarkdownNode *)findNodeWithId:(NSString *)nodeId inNode:(MarkdownNode *)node {
    if ([node.nodeId isEqualToString:nodeId]) {
        return node;
    }
    
    for (MarkdownNode *child in node.children) {
        MarkdownNode *found = [self findNodeWithId:nodeId inNode:child];
        if (found) return found;
    }
    
    return nil;
}

- (BOOL)isNode:(MarkdownNode *)node descendantOf:(MarkdownNode *)potentialAncestor {
    MarkdownNode *current = node;
    while (current) {
        if (current == potentialAncestor) {
            return YES;
        }
        current = current.parent;
    }
    return NO;
}

@end