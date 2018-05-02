
#import "qedefs.h"

/*

NOTE: I am specifically not using cached image reps, because the data is also needed for texturing the views, and a cached rep would waste tons of space.

*/

@implementation TextureView

- init
{
	deselectIndex = -1;
	return self;
}

- setParent:(id)from
{
	parent_i = from;
	return self;
}

#warning ViewConversion: 'acceptsFirstMouse:' (used to be 'acceptsFirstMouse') now takes the event as an arg
- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
	return YES;
}

#warning RectConversion: drawRect:(NSRect)rects (used to be drawSelf:(const NXRect *)rects :(int)rectCount) no longer takes an array of rects
- (void)drawRect:(NSRect)rects
{
	int		i;
	int		max;
	id		list_i;
	texpal_t *t;
	int		x;
	int		y;
	NSPoint	p;
	NSRect	r;
	int		selected;
	
	selected = [parent_i getSelectedTexture];
	list_i = [parent_i getList];
	PSselectfont("Helvetica-Medium",FONTSIZE);
	PSrotate(0);
	
	PSsetgray(NSLightGray);
	PSrectfill(rects.origin.x, rects.origin.y, 
		rects.size.width, rects.size.height);

	if (!list_i)		// WADfile didn't init
		return;

	if (deselectIndex != -1)
	{
		t = [list_i elementAt:deselectIndex];
		r = t->r;
		r.origin.x -= TEX_INDENT;
		r.origin.y -= TEX_INDENT;
		r.size.width += TEX_INDENT*2;
		r.size.height += TEX_INDENT*2;
		
		PSsetgray([[[NSColor lightGrayColor] colorUsingColorSpaceName:NSCalibratedWhiteColorSpace] whiteComponent]);
		PSrectfill(r.origin.x, r.origin.y,
			r.size.width, r.size.height);
		p = t->r.origin;
		p.y += TEX_SPACING;
		[t->image drawAtPoint:p];
		PSsetgray(0);
		x = t->r.origin.x;
		y = t->r.origin.y + 7;
		PSmoveto(x,y);
		PSshow(t->name);
		PSstroke();
		deselectIndex = -1;
	}

	max = [list_i count];
	PSsetgray(0);

	for (i = 0;i < max; i++)
	{
		t = [list_i elementAt:i];
		r = t->r;
		r.origin.x -= TEX_INDENT/2;
		r.size.width += TEX_INDENT;
		r.origin.y += 4;
		if (!NSIsEmptyRect(NSIntersectionRect(rects , r)) == YES &&
			t->display)
		{
			if (selected == i)
			{
				PSsetgray(1);
				PSrectfill(r.origin.x,r.origin.y,
					r.size.width,r.size.height);
				PSsetrgbcolor(1,0,0);
				PSrectstroke(r.origin.x, r.origin.y,
					 r.size.width, r.size.height);
				PSsetgray(0);
			}
			
			p = t->r.origin;
			p.y += TEX_SPACING;
			[t->image drawAtPoint:p];
			x = t->r.origin.x;
			y = t->r.origin.y + 7;
			PSmoveto(x,y);
			PSshow(t->name);
		}
	}
	PSstroke();
}

- deselect
{
	deselectIndex = [parent_i getSelectedTexture];
	return self;
}

- (void)mouseDown:(NSEvent *)theEvent 
{
	NSPoint	loc;
	int		i;
	int		max;
	int		oldwindowmask;
	texpal_t *t;
	id		list;
	NSRect	r;

#error EventConversion: addToEventMask:NX_LMOUSEDRAGGEDMASK: is obsolete; you no longer need to use the eventMask methods; for mouse moved events, see 'setAcceptsMouseMovedEvents:'
	oldwindowmask = [[self window] addToEventMask:NSLeftMouseDraggedMask];
	loc = [theEvent locationInWindow];
	loc = [self convertPoint:loc fromView:NULL];
	
	list = [parent_i getList];
	max = [list count];
	for (i = 0;i < max; i++)
	{
		t = [list elementAt:i];
		r = t->r;
		if (NSPointInRect(loc , r) == YES)
		{
			[self deselect]; 
			[parent_i	setSelectedTexture:i];
			break;
		}
	}
	
#error EventConversion: setEventMask:oldwindowmask: is obsolete; you no longer need to use the eventMask methods; for mouse moved events, see 'setAcceptsMouseMovedEvents:'
	[[self window] setEventMask:oldwindowmask];
}

@end
