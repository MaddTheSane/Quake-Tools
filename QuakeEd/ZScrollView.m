#import "qedefs.h"

@implementation ZScrollView

/*
====================
initFrame: button:

Initizes a scroll view with a button at it's lower right corner
====================
*/

- initFrame:(const NSRect *)frameRect button1:b1
{
	[super initWithFrame:*frameRect];	

	[self addSubview: b1];

	button1 = b1;

	[self setHasHorizontalScroller:YES];
	[self setHasVerticalScroller:YES];

	[self setBorderType:NSBezelBorder];
		
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
	scrollerframe = [[self horizontalScroller] frame];
	[button1 setFrame:scrollerframe];
	
	scrollerframe.size.width = 0;
	[[self horizontalScroller] setFrame:scrollerframe];
}



-(BOOL) acceptsFirstResponder
{
    return YES;
}

- (void)resizeWithOldSuperviewSize:(NSSize)oldSize
{
	[super resizeWithOldSuperviewSize:oldSize];
	
	[[self documentView] newSuperBounds];
}



@end

