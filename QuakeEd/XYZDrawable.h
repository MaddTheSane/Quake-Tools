//
//  XYZDrawable.h
//  QuakeEd
//
//  Created by C.W. Betts on 9/7/15.
//  Copyright © 2015 C.W. Betts. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol XYZDrawable /*<NSObject>*/
- (void)XYDrawSelf;
- (void)ZDrawSelf;

@optional
- (void)cameraDrawSelf;

@end
