//
//  List.m
//  QuakeEd
//
//  Created by C.W. Betts on 9/3/15.
//  Copyright © 2015 C.W. Betts. All rights reserved.
//

#import "List.h"

@implementation List

- (instancetype)init
{
	if (self = [super init]) {
		internalList = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)addObject:(id)obj
{
	[internalList addObject:obj];
}

- (id)objectAt:(int)index
{
	return [self objectAtIndex:index];
}

- (id)objectAtIndex:(NSInteger)index
{
	return [internalList objectAtIndex:index];
}

- (id)removeObject:(id)obj
{
	NSInteger aCount = [internalList count];
	[internalList removeObject:obj];
	if (aCount != [internalList count]) {
		return obj;
	} else {
		return nil;
	}
}

- (void)insertObject:(id)obj at:(int)idx
{
	[self insertObject:obj atIndex:idx];
}

- (void)insertObject:(id)obj atIndex:(NSInteger)idx
{
	[internalList insertObject:obj atIndex:idx];
}

- (void)empty
{
	[self removeAllObjects];
}

- (void)removeAllObjects
{
	[internalList removeAllObjects];
}

- (NSInteger)count
{
	return [internalList count];
}

- (void)removeObjectAt:(int)idx
{
	[self removeObjectAtIndex:idx];
}

- (void)removeObjectAtIndex:(NSInteger)idx
{
	[internalList removeObjectAtIndex:idx];
}

- (NSEnumerator*)objectEnumerator
{
	return [internalList objectEnumerator];
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len
{
	return [internalList countByEnumeratingWithState:state objects:buffer count:len];
}

- (void)dealloc
{
	[internalList release];
	
	[super dealloc];
}

@end
