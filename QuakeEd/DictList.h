
#import <AppKit/AppKit.h>
#import "QEOldListAPIs.h"

@interface DictList:NSObject
{

}

- initListFromFile:(FILE *)fp;
- writeListFile:(char *)filename;
- (id) findDictKeyword:(char *)key;

@end


@interface DictList(OldListAPIs) <QEOldListAPIs>
@end
