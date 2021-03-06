
#import "qedefs.h"

@implementation PopScrollView

/*
====================
initFrame: button:

Initizes a scroll view with a button at it's lower right corner
====================
*/

- initWithFrame:(NSRect)frameRect button1:b1 button2:b2
{
	self = [super  initWithFrame: frameRect];

	[self addSubview: b1];
	[self addSubview: b2];

	button1 = b1;
	button2 = b2;

	//[self setBorderType: NX_BEZEL];
		
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
	NSRect	buttonframe, buttonframe2;
	NSRect	newframe;
	
	[super tile];
	buttonframe = [button1 frame];
	buttonframe2 = [button2 frame];
	scrollerframe = [[self horizontalScroller] frame];

	newframe.origin.y = scrollerframe.origin.y;
	newframe.origin.x = _frame.size.width - buttonframe.size.width;
	newframe.size.width = buttonframe.size.width;
	newframe.size.height = scrollerframe.size.height;
	scrollerframe.size.width -= newframe.size.width;
	[button1 setFrame: newframe];
	newframe.size.width = buttonframe2.size.width;
	newframe.origin.x -= newframe.size.width;
	[button2 setFrame: newframe];
	scrollerframe.size.width -= newframe.size.width;

	[[self horizontalScroller] setFrame: scrollerframe];
}

- (void)superviewSizeChanged:(const NSSize *)oldSize
{
	//TODO:Update!
	//[super superviewSizeChanged: oldSize];
	
	[[self documentView] newSuperBounds];
}


-(BOOL) acceptsFirstResponder
{
    return YES;
}



@end

