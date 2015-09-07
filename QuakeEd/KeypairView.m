
#import "qedefs.h"

KeypairView *keypairview_i;

@implementation KeypairView

/*
==================
initFrame:
==================
*/
- (instancetype)initWithFrame:(NSRect)frameRect
{
	self = [super initWithFrame:frameRect];
	keypairview_i = self;
	return self;
}


- (void)calcViewSize
{
	NXCoord	w;
	NXCoord	h;
	NSRect	b;
	NSPoint	pt;
	int		count;
	id		ent;
	
	ent = [map_i currentEntity];
	count = [ent numPairs];

	[[self superview] setFlipped: YES];
	
	b = [[self superview] bounds];
	w = b.size.width;
	h = LINEHEIGHT*count + SPACING;
	//[self	sizeTo:w :h];
	pt.x = pt.y = 0;
	[self scrollPoint: pt];
}

- (void)drawRect:(NSRect)dirtyRect
{
	epair_t	*pair;
	int		y;
	//NSBezierPath *bPath = [NSBezierPath bezierPath];
	
#if 1
	[super drawRect:dirtyRect];
#else
	[[NSColor lightGrayColor] set];
	NSRect aFillRect;
	aFillRect.size = self.bounds.size;
	aFillRect.origin = NSZeroPoint;
	NSRectFill(aFillRect);
#endif
	NSFont *sysFont = [NSFont boldSystemFontOfSize:FONTSIZE];
	NSColor *textClr = [NSColor controlTextColor];
	NSDictionary *fDict = @{NSFontAttributeName: sysFont,
							NSForegroundColorAttributeName: textClr};
	//PSselectfont("Helvetica-Bold",FONTSIZE);
	//PSrotate(0);
	//PSsetgray(0);
	
	pair = [[map_i currentEntity] epairs];
	y = [self bounds].size.height - LINEHEIGHT;
	for ( ; pair ; pair=pair->next)
	{
		//[bPath moveToPoint:NSMakePoint(SPACING, y)];
		//PSmoveto(SPACING, y);
		[@(pair->key) drawAtPoint:NSMakePoint(SPACING, y) withAttributes:fDict];
		//PSshow(pair->key);
		[@(pair->value) drawAtPoint:NSMakePoint(100, y) withAttributes:fDict];
		//PSmoveto(100, y);
		//PSshow(pair->value);
		y -= LINEHEIGHT;
	}
	//PSstroke();
	//[bPath stroke];
}

- (void)mouseDown:(NSEvent *)theEvent
{
	NSPoint	loc;
	int		i;
	epair_t	*p;

	loc = [theEvent locationInWindow];
	loc = [self convertPoint:loc	fromView:NULL];
	
	i = (self.bounds.size.height - loc.y - 4) / LINEHEIGHT;

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
