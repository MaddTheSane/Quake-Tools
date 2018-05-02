//
//  QEOldListAPIs.h
//  QuakeEd
//
//  Created by C.W. Betts on 5/2/18.
//  Copyright © 2018 C.W. Betts. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol QEOldListAPIs <NSObject>
- (id)objectAt:(NSInteger)idx;
- (id)removeObject:(id) o;
- (void)addObject:(id)obj;
- (NSInteger)count;
- (void)empty;
@end
