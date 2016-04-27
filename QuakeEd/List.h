//
//  List.h
//  QuakeEd
//
//  Created by C.W. Betts on 9/3/15.
//  Copyright © 2015 C.W. Betts. All rights reserved.
//

#import <Foundation/Foundation.h>

#if !__OBJC2__
#import <objc/List.h>
#else
#define List QEList
#define maxElements [self count]
#define numElements [self count]
#endif

#define QLLIST_DEPRECATED(msg) __OSX_AVAILABLE_BUT_DEPRECATED_MSG(__MAC_10_0, __MAC_10_0, __IPHONE_NA, __IPHONE_NA, msg)

NS_ASSUME_NONNULL_BEGIN

///Simple wrapper emulating the NeXTStep `List` class.
@interface QEList : NSObject <NSFastEnumeration> {
	NSMutableArray *internalList;
}

- (instancetype)init NS_DESIGNATED_INITIALIZER;

- (void)addObject:(id)obj;
- (id)objectAt:(unsigned int)index QLLIST_DEPRECATED("Use -objectAtIndex: instead");
- (id)objectAtIndex:(NSInteger)index;
- (nullable id)removeObject:(id)obj;

- (void)insertObject:(id)obj at:(int)idx QLLIST_DEPRECATED("Use -insertObject:atIndex: instead");
- (void)insertObject:(id)obj atIndex:(NSInteger)idx;

- (void)empty QLLIST_DEPRECATED("Use -removeAllObjects instead");
- (void)removeAllObjects;

@property (readonly) NSInteger count;

- (void)removeObjectAt:(int)idx QLLIST_DEPRECATED("Use removeObjectAtIndex: instead");
- (void)removeObjectAtIndex:(NSInteger)idx;

- (NSEnumerator*)objectEnumerator;

@end
NS_ASSUME_NONNULL_END
