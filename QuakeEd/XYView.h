
#import <AppKit/AppKit.h>
#import "mathlib.h"
#import "SetBrush.h"

@class XYView;
extern XYView *xyview_i;

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

typedef NS_ENUM(NSInteger, XYDrawMode) {
	XYDrawModeWire,
	XYDrawModeFlat,
	XYDrawModeTexture,
	dr_wire = XYDrawModeWire,
	dr_flat = XYDrawModeFlat,
	dr_texture = XYDrawModeTexture,
};

typedef XYDrawMode drawmode_t;


@interface XYView :  NSView <NSDraggingSource>
{
	NSRect		realbounds, newrect, combinedrect;
	NSPoint		midpoint;
	int			gridsize;
	CGFloat		scale;

// for textured view
	int			xywidth, xyheight;
	float		*xyzbuffer;
	unsigned	*xypicbuffer;

	drawmode_t	drawmode;

// UI links
	IBOutlet NSMatrix		*mode_radio_i;
}
@property (nonatomic, assign) NSMatrix *modeRadio;

- (float)currentScale;

//- setModeRadio: m;

- (void)setDrawMode: (drawmode_t)mode;

- (void)newSuperBounds;
- (void)newRealBounds: (NSRect)nb;

- (void)addToScrollRange: (float)x :(float)y;
- (void)setOrigin: (NSPoint *)pt scale: (float)sc;
- (void)centerOn: (vec3_t)org;

- (IBAction)drawMode:(id) sender;

- (void)superviewChanged;

- (int)gridsize;
- (CGFloat)snapToGrid: (CGFloat)f;

@end
