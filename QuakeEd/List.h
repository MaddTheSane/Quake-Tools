//
//  List.h
//  QuakeEd
//
//  Created by C.W. Betts on 9/3/15.
//  Copyright © 2015 C.W. Betts. All rights reserved.
//

#import <Foundation/Foundation.h>

#define maxElements [self count]

///Simple wrapper around the NeXTStep `List` class.
@interface List : NSObject {
	NSMutableArray *internalList;
}

- (instancetype)init;

- (void)addObject:(id)obj;
- (id)objectAt:(int)index DEPRECATED_ATTRIBUTE;
- (id)objectAtIndex:(NSInteger)index;
- (id)removeObject:(id)obj;

- (void)insertObject:(id)obj at:(int)idx DEPRECATED_ATTRIBUTE;
- (void)insertObject:(id)obj atIndex:(NSInteger)idx;

- (void)empty DEPRECATED_ATTRIBUTE;
- (void)removeAllObjects;

@property (readonly) NSInteger count;

@end
