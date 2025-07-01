#ifndef NODE_CARD_VIEW_H
#define NODE_CARD_VIEW_H

#import <Cocoa/Cocoa.h>
#import "markdown_node.h"

@protocol NodeCardViewDelegate <NSObject>
- (void)nodeCardViewDidToggleExpansion:(NSView *)cardView;
- (void)nodeCardViewDidRequestEdit:(NSView *)cardView;
@end

@interface NodeCardView : NSView

@property (nonatomic, strong) MarkdownNode *node;
@property (nonatomic, weak) id<NodeCardViewDelegate> delegate;
@property (nonatomic, assign) BOOL isSelected;

- (void)updateWithNode:(MarkdownNode *)node;

@end

@interface NodeCollectionViewItem : NSCollectionViewItem

@property (nonatomic, strong) NodeCardView *cardView;

@end

#endif