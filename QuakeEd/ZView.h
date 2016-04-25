
#import <AppKit/AppKit.h>
#import "mathlib.h"
#import "XYZDrawable.h"

@class ZView;
extern ZView *zview_i;

// zplane controls the objects displayed in the xyview
extern	float	zplane;
extern	float	zplanedir;

@interface ZView : NSView <XYZDrawable>
{
	float		minheight, maxheight;
	float		oldminheight, oldmaxheight;
	float		topbound, bottombound;		// for floor clipping
	
	float		scale;
	
	vec3_t		origin;
}

- (void)clearBounds;
- (void)getBounds: (float *)top :(float *)bottom;

- getPoint: (NSPoint *)pt;
- setPoint: (NSPoint *)pt;

- (void)addToHeightRange: (float)height;

- (void)newRealBounds;
- (void)newSuperBounds;

- (void)XYDrawSelf;

- (BOOL)XYmouseDown: (NSPoint *)pt;

- (void)setXYOrigin: (NSPoint *)pt;

- (void)setOrigin: (NSPoint)pt scale: (float)sc;

@end

