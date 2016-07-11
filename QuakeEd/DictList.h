
#import <Foundation/Foundation.h>

@class Dict;

@interface DictList: NSObject
{
	NSMutableArray<Dict*> *intList;
}

- (instancetype)initListFromFile:(FILE *)fp;
- (void)writeListFile:(NSString *)filename;
- (Dict*) findDictKeyword:(NSString *)key;

@end
