
#import <AppKit/AppKit.h>

@class Clipper;
extern	Clipper	*clipper_i;

@interface Clipper : NSObject
{
	int			num;
	vec3_t		pos[3];
	plane_t		plane;
}

- (BOOL)hide;
- (void)XYClick: (NSPoint)pt;
- (BOOL)XYDrag: (NSPoint)pt;
- (void)ZClick: (NSPoint)pt;
- (void)carve;
- (void)flipNormal;
- (BOOL)getFace: (face_t *)pl;

- (void)cameraDrawSelf;
- (void)XYDrawSelf;
- (void)ZDrawSelf;

@end

