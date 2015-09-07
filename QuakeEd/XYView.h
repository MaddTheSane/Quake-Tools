
#import <AppKit/AppKit.h>
#import "mathlib.h"
#import "SetBrush.h"

@class XYView;

extern	XYView *xyview_i;

#define	MINSCALE	0.125
#define	MAXSCALE	2.0


extern	vec3_t		xy_viewnormal;		// v_forward for xy view
extern	float		xy_viewdist;		// clip behind this plane

extern	NSRect	xy_draw_rect;

void linestart (float r, float g, float b);
void lineflush (void);
void linecolor (float r, float g, float b);

void XYmoveto (vec3_t pt);
void XYlineto (vec3_t pt);

typedef NS_ENUM(NSInteger, drawmode_t) {dr_wire, dr_flat, dr_texture};


@interface XYView :  NSView
{
	NSRect		realbounds, newrect, combinedrect;
	NSPoint		midpoint;
	int			gridsize;
	float		scale;

// for textured view
	int			xywidth, xyheight;
	float		*xyzbuffer;
	unsigned	*xypicbuffer;

	drawmode_t	drawmode;

// UI links
	IBOutlet NSMatrix		*mode_radio_i;
}

- (float)currentScale;

- setModeRadio: m;

- setDrawMode: (drawmode_t)mode;

- newSuperBounds;
- newRealBounds: (NSRect *)nb;

- addToScrollRange: (float)x :(float)y;
- setOrigin: (NSPoint *)pt scale: (float)sc;
- centerOn: (vec3_t)org;

- (IBAction)drawMode:(id) sender;

- superviewChanged;

- (int)gridsize;
- (float)snapToGrid: (float)f;

@end
