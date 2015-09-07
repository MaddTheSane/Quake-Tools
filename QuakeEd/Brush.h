#import <AppKit/AppKit.h>
#import "SetBrush.h"
#import "EditWindow.h"

extern	id	brush_i;

extern	BOOL	brushdraw;			// YES when drawing cutbrushes and ents

@interface Brush : SetBrush
{
	id			cutbrushes_i;
	id			cutentities_i;
	boolean		updatemask[MAXBRUSHVERTEX];
	BOOL		dontdraw;				// for modal instance loops	
	BOOL		deleted;				// when not visible at all	
}

- (instancetype)init;

- (instancetype)initFromSetBrush: br;

- (void)deselect;
@property (readonly, getter=isSelected) BOOL selected;

- (BOOL)XYmouseDown: (NSPoint *)pt;		// return YES if brush handled
- (BOOL)ZmouseDown: (NSPoint *)pt;		// return YES if brush handled

- (void)keyDown:(NSEvent *)theEvent;

- (NSPoint)centerPoint;						// for camera flyby mode

- InstanceSize;
- XYDrawSelf;
- ZDrawSelf;
- CameraDrawSelf;

- (IBAction)flipHorizontal: sender;
- (IBAction)flipVertical: sender;
- (IBAction)rotate90: sender;

- (IBAction)makeTall: sender;
- (IBAction)makeShort: sender;
- (IBAction)makeWide: sender;
- (IBAction)makeNarrow: sender;

- (IBAction)placeEntity: sender;

- (IBAction)cut: sender;
- (IBAction)copy: sender;

- addBrush;

@end


