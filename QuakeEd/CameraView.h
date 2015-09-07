#import <AppKit/AppKit.h>
#import "mathlib.h"
#import "SetBrush.h"
#import "XYZDrawable.h"
//TODO: PORT TO OPENGL!

@class CameraView;
extern CameraView *cameraview_i;

extern	byte	renderlist[1024*1024*4];

void CameraMoveto(vec3_t p);
void CameraLineto(vec3_t p);

extern	BOOL	timedrawing;

@interface CameraView :  NSView <XYZDrawable>
{
	float		xa, ya, za;
	float		move;
		
	float		*zbuffer;
	unsigned	*imagebuffer;
	
	BOOL		angleChange;		// JR 6.8.95
	
	vec3_t		origin;
	vec3_t		matrix[3];
	
	NSPoint		dragspot;
	
	drawmode_t	drawmode;
	
// UI links
	IBOutlet NSMatrix			*mode_radio_i;
	
}

- (void)setXYOrigin: (NSPoint)pt;
- (void)setZOrigin: (float)pt;

- (void)setOrigin: (vec3_t)org angle: (float)angle;
- (void)getOrigin: (vec3_t)org;

- (float)yawAngle;

- (void)matrixFromAngles;
- (void)keyDown: (NSEvent *)theEvent;

- (IBAction)drawMode:(id) sender;
- (void)setDrawMode: (drawmode_t)mode;

- (IBAction)homeView:(id) sender;

- (void)XYDrawSelf;						// for drawing viewpoint in XY view
- (void)ZDrawSelf;						// for drawing viewpoint in XY view
- (BOOL)XYmouseDown: (NSPoint *)pt flags:(int)flags;	// return YES if brush handled
- (BOOL)ZmouseDown: (NSPoint *)pt flags:(int)flags;	// return YES if brush handled

- (IBAction)upFloor:sender;
- (IBAction)downFloor: sender;

@end

