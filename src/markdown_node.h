#ifndef MARKDOWN_NODE_H
#define MARKDOWN_NODE_H

#import <Foundation/Foundation.h>

@interface MarkdownNode : NSObject

@property (nonatomic, strong) NSString *nodeId;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSMutableArray<MarkdownNode *> *children;
@property (nonatomic, weak) MarkdownNode *parent;
@property (nonatomic, assign) BOOL isExpanded;
@property (nonatomic, readonly) NSInteger nestingLevel;

- (instancetype)initWithTitle:(NSString *)title content:(NSString *)content;
- (void)addChild:(MarkdownNode *)child;
- (void)removeChild:(MarkdownNode *)child;
- (void)insertChild:(MarkdownNode *)child atIndex:(NSInteger)index;
- (NSArray<MarkdownNode *> *)flattenedDescendants;
- (NSString *)generateMarkdown;

@end

#endif