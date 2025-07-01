#ifndef OUTLINER_PROTOCOL_H
#define OUTLINER_PROTOCOL_H

#import <Cocoa/Cocoa.h>
#import "markdown_node.h"

@protocol OutlinerDelegate <NSObject>
- (void)outlinerDidSelectNode:(MarkdownNode *)node;
- (void)outlinerDidUpdateStructure;
@end

@protocol OutlinerViewController <NSObject>

@required
@property (nonatomic, strong) MarkdownNode *rootNode;
@property (nonatomic, weak) id<OutlinerDelegate> delegate;
@property (nonatomic, readonly) NSView *view;

- (void)reloadData;
- (void)selectNode:(MarkdownNode *)node;

@end

#endif