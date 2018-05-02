
#import "qedefs.h"

id	keypairview_i;

@implementation KeypairView

/*
==================
initFrame:
==================
*/
- initWithFrame:(NSRect)frameRect
{
	[super initWithFrame:frameRect];
	keypairview_i = self;
	return self;
}


- calcViewSize
{
	float	w;
	float	h;
	NSRect	b;
	NSPoint	pt;
	int		count;
	id		ent;
	
	ent = [map_i currentEntity];
	count = [ent numPairs];

#error ViewConversion: '[NSView setFlipped:]' is obsolete; you must override 'isFlipped' instead of setting externally. However, [NSImage setFlipped:] is not obsolete. If that is what you are using here, no change is needed.
	[[self superview] setFlipped:YES];
	
	b = [[self superview] bounds];
	w = b.size.width;
	h = LINEHEIGHT*count + SPACING;
	[self setFrameSize:NSMakeSize(w, h)];
	pt.x = pt.y = 0;
	[self scrollPoint:pt];
	return self;
}

#warning RectConversion: drawRect:(NSRect)rects (used to be drawSelf:(const NXRect *)rects :(int)rectCount) no longer takes an array of rects
- (void)drawRect:(NSRect)rects
{
	epair_t	*pair;
	int		y;
	
	PSsetgray([[[NSColor lightGrayColor] colorUsingColorSpaceName:NSCalibratedWhiteColorSpace] whiteComponent]);
	PSrectfill(0,0,[self bounds].size.width,[self bounds].size.height);
		
	PSselectfont("Helvetica-Bold",FONTSIZE);
	PSrotate(0);
	PSsetgray(0);
	
	pair = [[map_i currentEntity] epairs];
	y = [self bounds].size.height - LINEHEIGHT;
	for ( ; pair ; pair=pair->next)
	{
		PSmoveto(SPACING, y);
		PSshow(pair->key);
		PSmoveto(100, y);
		PSshow(pair->value);
		y -= LINEHEIGHT;
	}
	PSstroke();
}

- (void)mouseDown:(NSEvent *)theEvent 
{
	NSPoint	loc;
	int		i;
	epair_t	*p;

	loc = [theEvent locationInWindow];
	loc = [self convertPoint:loc fromView:NULL];
	
	i = ([self bounds].size.height - loc.y - 4) / LINEHEIGHT;

	p = [[map_i currentEntity] epairs];
	while (	i )
	{
		p=p->next;
		if (!p)
			return;
		i--;
	}
	if (p)
		[things_i setSelectedKey: p];
}

@end
