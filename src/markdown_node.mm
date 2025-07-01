#import "markdown_node.h"

@implementation MarkdownNode

- (instancetype)initWithTitle:(NSString *)title content:(NSString *)content {
    self = [super init];
    if (self) {
        _nodeId = [[NSUUID UUID] UUIDString];
        _title = title ?: @"";
        _content = content ?: @"";
        _children = [NSMutableArray array];
        _isExpanded = YES;
    }
    return self;
}

- (void)addChild:(MarkdownNode *)child {
    [self.children addObject:child];
    child.parent = self;
}

- (void)removeChild:(MarkdownNode *)child {
    [self.children removeObject:child];
    child.parent = nil;
}

- (void)insertChild:(MarkdownNode *)child atIndex:(NSInteger)index {
    [self.children insertObject:child atIndex:index];
    child.parent = self;
}

- (NSInteger)nestingLevel {
    NSInteger level = 0;
    MarkdownNode *current = self.parent;
    while (current) {
        level++;
        current = current.parent;
    }
    return level;
}

- (NSArray<MarkdownNode *> *)flattenedDescendants {
    NSMutableArray *result = [NSMutableArray array];
    [result addObject:self];
    
    if (self.isExpanded) {
        for (MarkdownNode *child in self.children) {
            [result addObjectsFromArray:[child flattenedDescendants]];
        }
    }
    
    return result;
}

- (NSString *)generateMarkdown {
    NSMutableString *markdown = [NSMutableString string];
    
    NSInteger level = self.nestingLevel;
    for (NSInteger i = 0; i < level + 1; i++) {
        [markdown appendString:@"#"];
    }
    [markdown appendFormat:@" %@\n\n", self.title];
    
    if (self.content.length > 0) {
        [markdown appendFormat:@"%@\n\n", self.content];
    }
    
    for (MarkdownNode *child in self.children) {
        [markdown appendString:[child generateMarkdown]];
    }
    
    return markdown;
}

@end