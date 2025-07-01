#import "outliner_view_controller.h"
#import "node_card_view.h"

static NSString *const kNodeItemIdentifier = @"NodeItemIdentifier";
static NSString *const kNodePasteboardType = @"com.mdknit.node";

@interface OutlinerViewController () <NodeCardViewDelegate, NSCollectionViewDelegateFlowLayout>
@property (nonatomic, strong) NSCollectionView *collectionView;
@property (nonatomic, strong) NSScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray<MarkdownNode *> *flattenedNodes;
@property (nonatomic, strong) MarkdownNode *selectedNode;
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
    MarkdownNode *node = self.flattenedNodes[indexPath.item];
    NSPasteboardItem *pbItem = [[NSPasteboardItem alloc] init];
    [pbItem setString:node.nodeId forType:kNodePasteboardType];
    return pbItem;
}

- (NSDragOperation)collectionView:(NSCollectionView *)collectionView 
                     validateDrop:(id<NSDraggingInfo>)draggingInfo 
                proposedIndexPath:(NSIndexPath **)proposedDropIndexPath 
                    dropOperation:(NSCollectionViewDropOperation *)proposedDropOperation {
    if (*proposedDropOperation == NSCollectionViewDropBefore) {
        return NSDragOperationMove;
    }
    return NSDragOperationNone;
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
    
    if (indexPath.item < self.flattenedNodes.count) {
        MarkdownNode *targetNode = self.flattenedNodes[indexPath.item];
        NSInteger targetIndex = [targetNode.parent.children indexOfObject:targetNode];
        [targetNode.parent insertChild:draggedNode atIndex:targetIndex];
    } else if (self.flattenedNodes.count > 0) {
        MarkdownNode *lastNode = self.flattenedNodes.lastObject;
        [lastNode.parent addChild:draggedNode];
    } else {
        [self.rootNode addChild:draggedNode];
    }
    
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

@end