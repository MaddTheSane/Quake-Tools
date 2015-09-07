#import "qedefs.h"

@implementation ZScrollView

/*
====================
initFrame: button:

Initizes a scroll view with a button at it's lower right corner
====================
*/

- (instancetype)initWithFrame:(NSRect)frameRect button1:b1
{
	self = [super initWithFrame: frameRect];

	[self addSubview: b1];

	button1 = b1;

	[self setHorizontalScrollerRequired: YES];
	[self setVerticalScrollerRequired: YES];
	self.borderType = NSBezelBorder;
	
	return self;
}


/*
================
tile

Adjust the size for the pop up scale menu
=================
*/

- (void)tile
{
	NSRect	scrollerframe;
	
	[super tile];
	scrollerframe = [self horizontalScroller].frame;
	//button1
	[button1 setFrame: scrollerframe];
	
	scrollerframe.size.width = 0;
	[[self horizontalScroller] setFrame: scrollerframe];
}



-(BOOL) acceptsFirstResponder
{
    return YES;
}

- superviewSizeChanged:(const NSSize *)oldSize
{
	[super superviewSizeChanged: oldSize];
	
	[[self documentView] newSuperBounds];
	
	return self;
}



@end

