
#import <AppKit/AppKit.h>
#import "List.h"

@class Dict;

@interface DictList: List
{
}

- (instancetype)initListFromFile:(FILE *)fp;
- (void)writeListFile:(NSString *)filename;
- (Dict*) findDictKeyword:(NSString *)key;

@end
