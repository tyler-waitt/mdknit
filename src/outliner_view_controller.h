#ifndef OUTLINER_VIEW_CONTROLLER_H
#define OUTLINER_VIEW_CONTROLLER_H

#import <Cocoa/Cocoa.h>
#import "markdown_node.h"

@protocol OutlinerViewControllerDelegate <NSObject>
- (void)outlinerDidSelectNode:(MarkdownNode *)node;
- (void)outlinerDidUpdateStructure;
@end

@interface OutlinerViewController : NSViewController <NSCollectionViewDataSource, NSCollectionViewDelegate>

@property (nonatomic, strong) MarkdownNode *rootNode;
@property (nonatomic, weak) id<OutlinerViewControllerDelegate> delegate;

- (void)reloadData;
- (void)selectNode:(MarkdownNode *)node;

@end

#endif