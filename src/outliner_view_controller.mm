#import "outliner_view_controller.h"
#import "node_card_view.h"

static NSString *const kNodeItemIdentifier = @"NodeItemIdentifier";
static NSString *const kNodePasteboardType = @"com.mdknit.node";

@interface OutlinerViewController () <NodeCardViewDelegate, NSCollectionViewDelegateFlowLayout>
@property (nonatomic, strong) NSCollectionView *collectionView;
@property (nonatomic, strong) NSScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray<MarkdownNode *> *flattenedNodes;
@property (nonatomic, strong) MarkdownNode *selectedNode;
@property (nonatomic, strong) NSIndexPath *draggedIndexPath;
@property (nonatomic, strong) NSIndexPath *dropTargetIndexPath;
@property (nonatomic, assign) NSCollectionViewDropOperation currentDropOperation;
@end

@implementation OutlinerViewController

- (void)loadView {
    self.view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 300, 600)];
    
    NSCollectionViewFlowLayout *layout = [[NSCollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 2;
    layout.minimumInteritemSpacing = 0;
    layout.sectionInset = NSEdgeInsetsMake(12, 12, 12, 12);
    
    self.collectionView = [[NSCollectionView alloc] init];
    self.collectionView.collectionViewLayout = layout;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.selectable = YES;
    self.collectionView.allowsMultipleSelection = NO;
    self.collectionView.backgroundColors = @[NSColor.windowBackgroundColor];
    
    [self.collectionView registerClass:[NodeCollectionViewItem class] 
                 forItemWithIdentifier:kNodeItemIdentifier];
    
    [self.collectionView registerForDraggedTypes:@[kNodePasteboardType]];
    [self.collectionView setDraggingSourceOperationMask:NSDragOperationMove forLocal:YES];
    
    self.scrollView = [[NSScrollView alloc] init];
    self.scrollView.documentView = self.collectionView;
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
    
    [self rebuildFlattenedNodes];
}

- (void)rebuildFlattenedNodes {
    self.flattenedNodes = [NSMutableArray array];
    for (MarkdownNode *child in self.rootNode.children) {
        [self.flattenedNodes addObjectsFromArray:[child flattenedDescendants]];
    }
}

- (void)reloadData {
    [self rebuildFlattenedNodes];
    [self.collectionView reloadData];
}

- (void)selectNode:(MarkdownNode *)node {
    self.selectedNode = node;
    NSInteger index = [self.flattenedNodes indexOfObject:node];
    if (index != NSNotFound) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        NSSet *indexPaths = [NSSet setWithObject:indexPath];
        [self.collectionView selectItemsAtIndexPaths:indexPaths scrollPosition:NSCollectionViewScrollPositionCenteredVertically];
    }
}

#pragma mark - NSCollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(NSCollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.flattenedNodes.count;
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView 
     itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath {
    NodeCollectionViewItem *item = [collectionView makeItemWithIdentifier:kNodeItemIdentifier 
                                                              forIndexPath:indexPath];
    
    MarkdownNode *node = self.flattenedNodes[indexPath.item];
    item.cardView.delegate = self;
    [item.cardView updateWithNode:node];
    item.cardView.isSelected = (node == self.selectedNode);
    
    return item;
}

#pragma mark - NSCollectionViewDelegate

- (void)collectionView:(NSCollectionView *)collectionView didSelectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths {
    NSIndexPath *indexPath = indexPaths.anyObject;
    if (indexPath) {
        self.selectedNode = self.flattenedNodes[indexPath.item];
        [self.delegate outlinerDidSelectNode:self.selectedNode];
    }
}

#pragma mark - NSCollectionViewDelegateFlowLayout

- (NSSize)collectionView:(NSCollectionView *)collectionView 
                  layout:(NSCollectionViewLayout *)collectionViewLayout 
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return NSMakeSize(collectionView.bounds.size.width - 24, 36);
}

#pragma mark - NodeCardViewDelegate

- (void)nodeCardViewDidToggleExpansion:(NSView *)cardView {
    NodeCardView *nodeCard = (NodeCardView *)cardView;
    nodeCard.node.isExpanded = !nodeCard.node.isExpanded;
    [self reloadData];
}

- (void)nodeCardViewDidRequestEdit:(NSView *)cardView {
    NodeCardView *nodeCard = (NodeCardView *)cardView;
    [self.delegate outlinerDidSelectNode:nodeCard.node];
}

#pragma mark - Drag and Drop

- (BOOL)collectionView:(NSCollectionView *)collectionView 
   canDragItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths 
              withEvent:(NSEvent *)event {
    return YES;
}

- (id<NSPasteboardWriting>)collectionView:(NSCollectionView *)collectionView 
                pasteboardWriterForItemAtIndexPath:(NSIndexPath *)indexPath {
    self.draggedIndexPath = indexPath;
    MarkdownNode *node = self.flattenedNodes[indexPath.item];
    NSPasteboardItem *pbItem = [[NSPasteboardItem alloc] init];
    [pbItem setString:node.nodeId forType:kNodePasteboardType];
    return pbItem;
}

- (void)collectionView:(NSCollectionView *)collectionView draggingSession:(NSDraggingSession *)session willBeginAtPoint:(NSPoint)screenPoint forItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths {
    for (NSIndexPath *indexPath in indexPaths) {
        NodeCollectionViewItem *item = (NodeCollectionViewItem *)[collectionView itemAtIndexPath:indexPath];
        item.cardView.alphaValue = 0.5;
    }
}

- (void)collectionView:(NSCollectionView *)collectionView draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)screenPoint dragOperation:(NSDragOperation)operation {
    if (self.draggedIndexPath) {
        NodeCollectionViewItem *item = (NodeCollectionViewItem *)[collectionView itemAtIndexPath:self.draggedIndexPath];
        item.cardView.alphaValue = 1.0;
    }
    self.draggedIndexPath = nil;
    self.dropTargetIndexPath = nil;
    [self updateDropIndicator];
}

- (NSDragOperation)collectionView:(NSCollectionView *)collectionView 
                     validateDrop:(id<NSDraggingInfo>)draggingInfo 
                proposedIndexPath:(NSIndexPath **)proposedDropIndexPath 
                    dropOperation:(NSCollectionViewDropOperation *)proposedDropOperation {
    NSPasteboard *pb = [draggingInfo draggingPasteboard];
    if (![pb canReadItemWithDataConformingToTypes:@[kNodePasteboardType]]) {
        return NSDragOperationNone;
    }
    
    if (*proposedDropIndexPath && self.draggedIndexPath) {
        if ([*proposedDropIndexPath isEqual:self.draggedIndexPath]) {
            return NSDragOperationNone;
        }
        
        MarkdownNode *draggedNode = self.flattenedNodes[self.draggedIndexPath.item];
        if (*proposedDropIndexPath != nil && (*proposedDropIndexPath).item < self.flattenedNodes.count) {
            MarkdownNode *targetNode = self.flattenedNodes[(*proposedDropIndexPath).item];
            if ([self isNode:targetNode descendantOf:draggedNode]) {
                return NSDragOperationNone;
            }
        }
    }
    
    NSPoint mouseLocation = [collectionView convertPoint:[draggingInfo draggingLocation] fromView:nil];
    if (*proposedDropIndexPath && (*proposedDropIndexPath).item < self.flattenedNodes.count) {
        NodeCollectionViewItem *item = (NodeCollectionViewItem *)[collectionView itemAtIndexPath:*proposedDropIndexPath];
        if (item) {
            NSRect itemFrame = item.view.frame;
            CGFloat relativeY = mouseLocation.y - itemFrame.origin.y;
            
            if (relativeY > itemFrame.size.height * 0.25 && relativeY < itemFrame.size.height * 0.75) {
                *proposedDropOperation = NSCollectionViewDropOn;
            }
        }
    }
    
    self.dropTargetIndexPath = *proposedDropIndexPath;
    self.currentDropOperation = *proposedDropOperation;
    [self updateDropIndicator];
    
    return NSDragOperationMove;
}

- (BOOL)collectionView:(NSCollectionView *)collectionView 
            acceptDrop:(id<NSDraggingInfo>)draggingInfo 
             indexPath:(NSIndexPath *)indexPath 
         dropOperation:(NSCollectionViewDropOperation)dropOperation {
    NSPasteboard *pb = [draggingInfo draggingPasteboard];
    NSString *nodeId = [pb stringForType:kNodePasteboardType];
    
    if (!nodeId) return NO;
    
    MarkdownNode *draggedNode = [self findNodeWithId:nodeId inNode:self.rootNode];
    if (!draggedNode) return NO;
    
    [draggedNode.parent removeChild:draggedNode];
    
    if (dropOperation == NSCollectionViewDropOn && indexPath.item < self.flattenedNodes.count) {
        MarkdownNode *targetNode = self.flattenedNodes[indexPath.item];
        [targetNode addChild:draggedNode];
        targetNode.isExpanded = YES;
    } else if (indexPath.item < self.flattenedNodes.count) {
        MarkdownNode *targetNode = self.flattenedNodes[indexPath.item];
        MarkdownNode *targetParent = targetNode.parent ?: self.rootNode;
        NSInteger targetIndex = [targetParent.children indexOfObject:targetNode];
        
        if (dropOperation == NSCollectionViewDropBefore) {
            [targetParent insertChild:draggedNode atIndex:targetIndex];
        } else {
            [targetParent insertChild:draggedNode atIndex:targetIndex + 1];
        }
    } else if (self.flattenedNodes.count > 0) {
        MarkdownNode *lastNode = self.flattenedNodes.lastObject;
        MarkdownNode *parent = lastNode.parent ?: self.rootNode;
        [parent addChild:draggedNode];
    } else {
        [self.rootNode addChild:draggedNode];
    }
    
    self.dropTargetIndexPath = nil;
    [self updateDropIndicator];
    [self reloadData];
    [self.delegate outlinerDidUpdateStructure];
    
    return YES;
}

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

- (void)updateDropIndicator {
    for (NSInteger i = 0; i < self.flattenedNodes.count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        NodeCollectionViewItem *item = (NodeCollectionViewItem *)[self.collectionView itemAtIndexPath:indexPath];
        if (!item) continue;
        
        if (self.dropTargetIndexPath && self.dropTargetIndexPath.item == i) {
            if (self.currentDropOperation == NSCollectionViewDropOn) {
                item.cardView.layer.borderColor = [[NSColor controlAccentColor] CGColor];
                item.cardView.layer.borderWidth = 2;
            } else {
                item.cardView.layer.borderColor = [[NSColor separatorColor] CGColor];
                item.cardView.layer.borderWidth = 1;
            }
        } else {
            item.cardView.layer.borderColor = [[NSColor separatorColor] CGColor];
            item.cardView.layer.borderWidth = 1;
        }
    }
}

@end