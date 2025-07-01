#ifndef TREE_OUTLINER_VIEW_CONTROLLER_H
#define TREE_OUTLINER_VIEW_CONTROLLER_H

#import <Cocoa/Cocoa.h>
#import "outliner_protocol.h"
#import "markdown_node.h"

@interface TreeOutlinerViewController : NSViewController <OutlinerViewController, NSOutlineViewDataSource, NSOutlineViewDelegate>

@property (nonatomic, strong) MarkdownNode *rootNode;
@property (nonatomic, weak) id<OutlinerDelegate> delegate;

- (void)reloadData;
- (void)selectNode:(MarkdownNode *)node;

@end

#endif