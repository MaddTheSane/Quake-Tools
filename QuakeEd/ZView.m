
#import "qedefs.h"

ZView *zview_i;

ZScrollView *zscrollview_i;
NSMenu *zscalemenu_i;
NSPopUpButton *zscalebutton_i;

float	zplane;
float	zplanedir;

@implementation ZView 

/*
==================
initFrame:
==================
*/
- (instancetype)initWithFrame:(NSRect)frameRect
{
	NSPoint	pt;
	
	origin[0] = 0.333;
	origin[1] = 0.333;
	
	self = [super initWithFrame:frameRect];
	//[self allocateGState];
	[self clearBounds];
	
	zview_i = self;
	scale = 1;
	
//		
// initialize the pop up menus
//
	zscalebutton_i = [[NSPopUpButton alloc] init];
	
	zscalemenu_i = [[NSMenu alloc] init];
	[zscalebutton_i setTarget: self];
	[zscalebutton_i setAction: @selector(scaleMenuTarget:)];

	[zscalemenu_i addItemWithTitle:@"12.5%" action:nil keyEquivalent:@""];
	[zscalemenu_i addItemWithTitle:@"25%" action:nil keyEquivalent:@""];
	[zscalemenu_i addItemWithTitle:@"50%" action:nil keyEquivalent:@"" ];
	[zscalemenu_i addItemWithTitle:@"75%" action:nil keyEquivalent:@""];
	[zscalemenu_i addItemWithTitle:@"100%" action:nil keyEquivalent:@""];
	[zscalemenu_i addItemWithTitle:@"200%" action:nil keyEquivalent:@""];
	[zscalemenu_i addItemWithTitle:@"300%" action:nil keyEquivalent:@""];
	[zscalebutton_i setMenu:zscalemenu_i];
	[zscalebutton_i selectItemAtIndex:4];

// initialize the scroll view
	zscrollview_i = [[ZScrollView alloc] 
		initWithFrame: 		frameRect
		button1: 		zscalebutton_i
	];
	zscrollview_i.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;

	[zscrollview_i setDocumentView: self];

//	[[self superview] setDrawOrigin: 0 : 0];

	minheight = 0;
	maxheight = 64;

	pt.x = -[self bounds].size.width;
	pt.y = -128;

	[self newRealBounds];
	
	[self setOrigin: pt scale: 1];
	
	//return zscrollview_i;
	return self;
}

- (void)setXYOrigin: (NSPoint *)pt
{
	origin[0] = pt->x + 0.333;
	origin[1] = pt->y + 0.333;
}

- (float)currentScale
{
	return scale;
}

/*
===================
setOrigin:scale:
===================
*/
- (void)setOrigin: (NSPoint)pt scale: (float)sc
{
	NSRect		sframe;
	NSRect		newbounds;
	
//
// calculate the area visible in the cliprect
//
	scale = sc;
	sframe = newbounds = self.superview.frame;
	
	newbounds.origin = pt;
	newbounds.size.width /= scale; 
	newbounds.size.height /= scale; 
	
//
// union with the realbounds
//
	if (newbounds.origin.y > oldminheight)
	{
		newbounds.size.height += newbounds.origin.y - oldminheight;
		newbounds.origin.y = oldminheight;
	}
	if (newbounds.origin.y+newbounds.size.height < oldmaxheight)
	{
		newbounds.size.height += oldmaxheight
		 - (newbounds.origin.y + newbounds.size.height);
	}

//
// redisplay everything
//
	[quakeed_i disableFlushWindow];

//
// size this view
//
	[self sizeTo: newbounds.size.width : newbounds.size.height];
	[self setDrawOrigin: -newbounds.size.width/2 : newbounds.origin.y];
	[self moveTo: -newbounds.size.width/2 : newbounds.origin.y];
	
//
// scroll and scale the clip view
//
	[[self superview] setDrawSize
		: sframe.size.width/scale 
		: sframe.size.height/scale];
	[[self superview] setDrawOrigin: pt.x : pt.y];

	[quakeed_i enableFlushWindow];
	[zscrollview_i setNeedsDisplay:YES];
}


/*
====================
scaleMenuTarget:

Called when the scaler popup on the window is used
====================
*/
- (IBAction)scaleMenuTarget:(id) sender
{
	NSRect		visrect, sframe;
	float		nscale;
	NSScanner	*scanner;
	
	NSString *item = [[sender selectedCell] title];
	scanner = [NSScanner scannerWithString:item];
	[scanner scanFloat:&nscale];
	nscale /= 100;
	
	if (nscale == scale)
		return;
		
// keep the center of the view constant
	visrect = self.superview.bounds;
	sframe = self.superview.frame;
	visrect.origin.x += visrect.size.width/2;
	visrect.origin.y += visrect.size.height/2;
	
	visrect.origin.x -= sframe.size.width/2/nscale;
	visrect.origin.y -= sframe.size.height/2/nscale;
	
	[self setOrigin: visrect.origin scale: nscale];
}


- (void)clearBounds
{
	topbound = 999999;
	bottombound = -999999;
}

- (void)getBounds: (float *)top :(float *)bottom;
{
	*top = topbound;
	*bottom = bottombound;
}


/*
==================
addToHeightRange:
==================
*/
- (void)addToHeightRange: (float)height
{
	if (height < minheight)
		minheight = height;
	if (height > maxheight)
		maxheight = height;
}


/*
==================
newSuperBounds

When superview is resized
==================
*/
- (void)newSuperBounds
{	
	oldminheight++;
	[self newRealBounds];
}


/*
===================
newRealBounds

Should only change the scroll bars, not cause any redraws.
If realbounds has shrunk, nothing will change.
===================
*/
- (void)newRealBounds
{
	NSRect		sbounds;
	float		vistop, visbottom;

	if (minheight == oldminheight && maxheight == oldmaxheight)
		return;
		
	oldminheight = minheight;
	oldmaxheight = maxheight;
		
	minheight -= 16;
	maxheight += 16;
	
//
// calculate the area visible in the cliprect
//
	sbounds = self.superview.bounds;
	visbottom = sbounds.origin.y;
	vistop = visbottom + sbounds.size.height;
	
	if (vistop > maxheight)
		maxheight = vistop;
	if (visbottom < minheight)
		minheight = visbottom;
	if (minheight == [self bounds].origin.y && maxheight-minheight == [self bounds].size.height)
		return;
		
	sbounds.origin.y = minheight;
	sbounds.size.height = maxheight - minheight;

//
// size this view
//
	[quakeed_i disableFlushWindow];

	[self suspendNotifyAncestorWhenFrameChanged:YES];
	[self sizeTo: sbounds.size.width : sbounds.size.height];
	[self setDrawOrigin: -sbounds.size.width/2 : sbounds.origin.y];
	[self moveTo: -sbounds.size.width/2 : sbounds.origin.y];
	[self suspendNotifyAncestorWhenFrameChanged:NO];
	[[[self superview] superview] reflectScrolledClipView: (NSClipView*)[self superview]];

	[quakeed_i enableFlushWindow];
	
	[[(NSScrollView*)[[self superview] superview] verticalScroller] display];
}



/*
============
drawGrid

Draws tile markings every 64 units, and grid markings at the grid scale if
the grid lines are >= 4 pixels apart

Rect is in global world (unscaled) coordinates
============
*/

- (void)drawGrid: (NSRect)rect
{
	int		y, stopy;
	CGFloat	top,bottom;
	CGFloat	left, right;
	int		gridsize;
	char	text[10];
	BOOL	showcoords;
	
	showcoords = [quakeed_i showCoordinates];
	
	NSBezierPath *path = [NSBezierPath bezierPath];
	path.lineWidth = 0;
	//PSsetlinewidth (0);

	gridsize = [xyview_i gridsize];
	
	left = self.bounds.origin.x;
	right = 24;
	
	bottom = rect.origin.y-1;
	top = rect.origin.y+rect.size.height+2;

//
// grid
//
// can't just divide by grid size because of negetive coordinate
// truncating direction
//
	if (gridsize>= 4/scale)
	{
		y = floor(bottom/gridsize);
		stopy = floor(top/gridsize);
		
		y *= gridsize;
		stopy *= gridsize;
		if (y<bottom)
			y+= gridsize;
			
		//beginUserPath (upath,NO);
		
		for ( ; y<=stopy ; y+= gridsize)
			if (y&31)
			{
				
				UPmoveto (upath, left, y);
				UPlineto (upath, right, y);
			}
	
		//endUserPath (upath, dps_ustroke);
		//PSsetrgbcolor (0.8,0.8,1.0);	// thin grid color
		sendUserPath (upath);
	}

//
// half tiles
//
	y = floor(bottom/32);
	stopy = floor(top/32);
	
	if ( ! (((int)y + 4096) & 1) )
		y++;
	y *= 32;
	stopy *= 32;
	if (stopy >= top)
		stopy -= 32;
	
	beginUserPath (upath,NO);
	
	for ( ; y<=stopy ; y+= 64)
	{
		UPmoveto (upath, left, y);
		UPlineto (upath, right, y);
	}

	//endUserPath (upath, dps_ustroke);
	[NSColor colorWithDeviceWhite:1 - (12.0 / 16.0) alpha:1];
	//PSsetgray (12.0/16.0);
	sendUserPath (upath);

//
// tiles
//
	y = floor(bottom/64);
	stopy = floor(top/64);
	
	y *= 64;
	stopy *= 64;
	if (y<bottom)
		y+= 64;
	if (stopy >= top)
		stopy -= 64;
		
	beginUserPath (upath,NO);
	PSsetgray (0);		// for text
	PSselectfont("Helvetica-Medium",10/scale);
	PSrotate(0);
	
	for ( ; y<=stopy ; y+= 64)
	{
		if (showcoords)
		{
			sprintf (text, "%i",y);
			PSmoveto(left,y);
			PSshow(text);
		}
		UPmoveto (upath, left+24, y);
		UPlineto (upath, right, y);
	}

// divider
	UPmoveto (upath, 0, _bounds.origin.y);
	UPlineto (upath, 0, _bounds.origin.y + _bounds.size.height);
	
	//endUserPath (upath, dps_ustroke);
	PSsetgray (10.0/16.0);
	sendUserPath (upath);

//
// origin
//
	PSsetlinewidth (5);
	PSsetgray (4.0/16.0);
	PSmoveto (right,0);
	PSlineto (left,0);
	PSstroke ();
	PSsetlinewidth (0.15);
}


- (void)drawZplane
{
	PSsetrgbcolor (0.2, 0.2, 0);
	PSarc (0, zplane, 4, 0, M_PI*2);
	PSfill ();
}

/*
===============================================================================
drawSelf
===============================================================================
*/

-(void)drawRect:(NSRect)dirtyRect
{
	NSRect		visRect;
	
	minheight = 999999;
	maxheight = -999999;

// allways draw the entire bar
	visRect = [self visibleRect];
	dirtyRect = visRect;

// erase window
	
	NSEraseRect (dirtyRect);
	
// draw grid
	[self drawGrid: dirtyRect];
	
// draw zplane
//	[self drawZplane];
	
// draw all entities
	[map_i makeUnselectedPerform: @selector(ZDrawSelf)];

// possibly resize the view
	[self newRealBounds];
}

/*
==============
XYDrawSelf
==============
*/
- XYDrawSelf
{
	PSsetrgbcolor (0,0.5,1.0);
	PSsetlinewidth (0.15);
	PSmoveto (origin[0]-16, origin[1]-16);
	PSrlineto (32,32);
	PSmoveto (origin[0]-16, origin[1]+16);
	PSrlineto (32,-32);
	PSstroke ();

	return self;
}


/*
==============
getPoint: (NSPoint *)pt
==============
*/
- (NSPoint)point
{
	NSPoint pt;
	pt.x = origin[0] + 0.333;	// offset a bit to avoid edge cases
	pt.y = origin[1] + 0.333;
	return pt;
}

- (void)setPoint: (NSPoint *)pt
{
	origin[0] = pt->x;
	origin[1] = pt->y;
}


/*
==============================================================================

MOUSE CLICKING

==============================================================================
*/


/*
================
dragLoop:
================
*/
static	NSPoint		oldreletive;
- dragFrom: (NSEvent *)startevent 
	useGrid: (BOOL)ug
	callback: (void (*) (float dy)) callback
{
	NSEvent		*event;
	NSPoint		startpt, newpt;
	NSPoint		reletive, delta;
	int		gridsize;

	gridsize = [xyview_i gridsize];
	
	startpt = startevent.locationInWindow;
	startpt = [self convertPoint:startpt  fromView:NULL];
	
	oldreletive.x = oldreletive.y = 0;
	
	while (1)
	{
		event = [NSApp nextEventMatchingMask:
			NSLeftMouseUpMask | NSLeftMouseDraggedMask
			| NSRightMouseUpMask | NSRightMouseDraggedMask];
		if (event.type == NSLeftMouseUp || event.type == NSRightMouseUp)
			break;
			
		newpt = event.locationInWindow;
		newpt = [self convertPoint:newpt  fromView:NULL];

		reletive.y = newpt.y - startpt.y;
		
		if (ug)
		{	// we want truncate towards 0 behavior here
			reletive.y = gridsize * (int)(reletive.y / gridsize);
		}

		if (reletive.y == oldreletive.y)
			continue;

		delta.y = reletive.y - oldreletive.y;
		oldreletive = reletive;			
		callback (delta.y);		
	}

	return self;
}

//============================================================================


void ZDragCallback (float dy)
{
	sb_translate[0] = 0;
	sb_translate[1] = 0;
	sb_translate[2] = dy;

	[map_i makeSelectedPerform: @selector(translate)];
	
	[quakeed_i redrawInstance];
}

- selectionDragFrom: (NSEvent*)theEvent	
{
	qprintf ("dragging selection");
	[self	dragFrom:	theEvent 
			useGrid:	YES
			callback:	ZDragCallback ];
	[quakeed_i updateCamera];
	qprintf ("");
	return self;
	
}

//============================================================================

void ZScrollCallback (float dy)
{
	NSRect		basebounds;
	NSPoint		neworg;
	float		scale;
	
	basebounds = [ [zview_i superview] bounds];
	[zview_i convertRectFromSuperview: basebounds];

	neworg.y = basebounds.origin.y - dy;
	
	scale = [zview_i currentScale];
	
	oldreletive.y -= dy;
	[zview_i setOrigin: neworg scale: scale];
}

- scrollDragFrom: (NSEvent*)theEvent	
{
	qprintf ("scrolling view");
	[self	dragFrom:	theEvent 
			useGrid:	YES
			callback:	ZScrollCallback ];
	qprintf ("");
	return self;
}

//============================================================================

void ZControlCallback (float dy)
{
	int		i;
	
	for (i=0 ; i<numcontrolpoints ; i++)
		controlpoints[i][2] += dy;
	
	[[map_i selectedBrush] calcWindings];	
	[quakeed_i redrawInstance];
}

- (BOOL)planeDragFrom: (NSEvent*)theEvent	
{
	NSPoint			pt;
	vec3_t			dragpoint;
	
	if ([map_i numSelected] != 1)
		return NO;

	pt= theEvent.locationInWindow;
	pt = [self convertPoint:pt  fromView:NULL];

	dragpoint[0] = origin[0];
	dragpoint[1] = origin[1];
	dragpoint[2] = pt.y;
	
	[[map_i selectedBrush] getZdragface: dragpoint];
	if (!numcontrolpoints)
		return NO;
	
	qprintf ("dragging brush plane");
	
	pt= theEvent.locationInWindow;
	pt = [self convertPoint:pt  fromView:NULL];

	[self	dragFrom:	theEvent 
			useGrid:	YES
			callback:	ZControlCallback ];
			
	[[map_i selectedBrush] removeIfInvalid];
	
	[quakeed_i updateCamera];
	qprintf ("");
	return YES;
}


//============================================================================

/*
===================
mouseDown
===================
*/
- (void)mouseDown:(NSEvent *)theEvent
{
	NSPoint	pt;
	NSEventModifierFlags		flags;
	vec3_t	p1;
	
	pt= theEvent.locationInWindow;
	pt = [self convertPoint:pt  fromView:NULL];

	p1[0] = origin[0];
	p1[1] = origin[1];
	p1[2] = pt.y;
	
	flags = theEvent.modifierFlags & (NSShiftKeyMask | NSControlKeyMask | NSAlternateKeyMask | NSCommandKeyMask);

//
// shift click to select / deselect a brush from the world
//
	if (flags == NSShiftKeyMask)
	{		
		[map_i selectRay: p1 : p1 : NO];
		return;
	}
		
//
// alt click = set entire brush texture
//
	if (flags == NSAlternateKeyMask)
	{
		[map_i setTextureRay: p1 : p1 : YES];
		return;
	}

//
// control click = position view
//
	if (flags == NSControlKeyMask)
	{
		[cameraview_i setZOrigin: pt.y];
		[quakeed_i updateAll];
		[cameraview_i ZmouseDown: &pt flags:theEvent.modifierFlags];
		return;
	}

//
// bare click to drag icons or new brush drag
//
	if ( flags == 0 )
	{
// check eye
		if ( [cameraview_i ZmouseDown: &pt flags:theEvent.modifierFlags] )
			return;
			
		if ([map_i numSelected])
		{
			if ( pt.x > 0)
			{
				if ([self planeDragFrom: theEvent])
					return;
			}
			[self selectionDragFrom: theEvent];
			return;
		}

	}
		
	qprintf ("bad flags for click");
	NopSound ();
}

/*
===================
rightMouseDown
===================
*/
- rightMouseDown:(NSEvent *)theEvent
{
	NSPoint	pt;
	int		flags;
		
	pt= theEvent.locationInWindow;
	pt = [self convertPoint:pt  fromView:NULL];

	flags = theEvent.modifierFlags & (NSShiftKeyMask | NSControlKeyMask | NSAlternateKeyMask | NSCommandKeyMask);

	
//
// click = scroll view
//
	if (flags == 0)
	{
		return [self scrollDragFrom: theEvent];		
	}

	qprintf ("bad flags for click");
	NopSound ();

	return self;
}


/*
===============================================================================

						XY mouse view methods

===============================================================================
*/

/*
================
modalMoveLoop
================
*/
- modalMoveLoop: (NSPoint *)basept :(vec3_t)movemod : converter
{
	vec3_t		originbase;	
	NSEvent		*event;
	NSPoint		newpt;
	vec3_t		delta;
	
	int			i;
	
	VectorCopy (origin, originbase);	
	
//
// modal event loop using instance drawing
//
	goto drawentry;

	while (event.type != NSLeftMouseUp)
	{
		//
		// calculate new point
		//
		newpt = event.locationInWindow;
		newpt = [converter convertPoint:newpt  fromView:NULL];
				
		delta[0] = newpt.x-basept->x;
		delta[1] = newpt.y-basept->y;
		delta[2] = delta[1];		// height change
		
		for (i=0 ; i<3 ; i++)
			origin[i] = originbase[i]+movemod[i]*delta[i];
		
					
drawentry:
		//
		// instance draw new frame
		//
		[quakeed_i newinstance];
		[self display];
		//NXPing ();
				
		event = [NSApp nextEventMatchingMask: 
			NSLeftMouseUpMask | NSLeftMouseDraggedMask];		
	}

//
// draw the brush back into the window buffer
//
//	[xyview_i display];
	
	return self;
}

/*
===============
XYmouseDown
===============
*/
- (BOOL)XYmouseDown: (NSPoint *)pt
{	
	vec3_t		movemod;
	
	if (fabs(pt->x - origin[0]) > 16
	|| fabs(pt->y - origin[1]) > 16)
		return NO;
		
	movemod[0] = 1;
	movemod[1] = 1;
	movemod[2] = 0;
	
	[self modalMoveLoop: pt : movemod : xyview_i];
	
	return YES;
}

@end
