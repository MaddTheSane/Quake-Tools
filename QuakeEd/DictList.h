
#import <AppKit/AppKit.h>
#import "List.h"

@interface DictList: List
{
}

- (instancetype)initListFromFile:(FILE *)fp;
- (void)writeListFile:(char *)filename;
- (id) findDictKeyword:(char *)key;

@end
