
#import "qedefs.h"

// Add .h-files here for new inspectors
#import	"Things.h"
#import	"TexturePalette.h"
#import	"Preferences.h"

id		inspcontrol_i;

@implementation InspectorControl

- (void)awakeFromNib
{
	inspcontrol_i = self;
		
	currentInspectorType = -1;

	contentList = [[List alloc] init];
	windowList = [[List alloc] init];
	itemList = [[List alloc] init];

	// ADD NEW INSPECTORS HERE...

	[windowList addObject:win_project_i];
	[contentList addObject:[win_project_i contentView]];
#error StringConversion: key equivalents are now instances of NSString. Change your C string variable to an NSString.
	[itemProject_i setKeyEquivalent:'1'];
	[itemList addObject:itemProject_i];

	[windowList addObject:win_textures_i];
	[contentList addObject:[win_textures_i contentView]];
#error StringConversion: key equivalents are now instances of NSString. Change your C string variable to an NSString.
	[itemTextures_i setKeyEquivalent:'2'];
	[itemList addObject:itemTextures_i];

	[windowList addObject:win_things_i];
	[contentList addObject:[win_things_i contentView]];
#error StringConversion: key equivalents are now instances of NSString. Change your C string variable to an NSString.
	[itemThings_i setKeyEquivalent:'3'];
	[itemList addObject:itemThings_i];
	
	[windowList addObject:win_prefs_i];
	[contentList addObject:[win_prefs_i contentView]];
#error StringConversion: key equivalents are now instances of NSString. Change your C string variable to an NSString.
	[itemPrefs_i setKeyEquivalent:'4'];
	[itemList addObject:itemPrefs_i];

	[windowList addObject:win_settings_i];
	[contentList addObject:[win_settings_i contentView]];
#error StringConversion: key equivalents are now instances of NSString. Change your C string variable to an NSString.
	[itemSettings_i setKeyEquivalent:'5'];
	[itemList addObject:itemSettings_i];

	[windowList addObject:win_output_i];
	[contentList addObject:[win_output_i contentView]];
#error StringConversion: key equivalents are now instances of NSString. Change your C string variable to an NSString.
	[itemOutput_i setKeyEquivalent:'6'];
	[itemList addObject:itemOutput_i];

	[windowList addObject:win_help_i];
	[contentList addObject:[win_help_i contentView]];
#error StringConversion: key equivalents are now instances of NSString. Change your C string variable to an NSString.
	[itemHelp_i setKeyEquivalent:'7'];
	[itemList addObject:itemHelp_i];

	// Setup inspector window with project subview first

	[inspectorView_i setAutoresizesSubviews:YES];

	inspectorSubview_i = [contentList objectAt:i_project];
	[inspectorView_i addSubview:inspectorSubview_i];

	currentInspectorType = -1;
	[self changeInspectorTo:i_project];
}


//
//	Sent by the PopUpList in the Inspector
//	Each cell in the PopUpList must have the correct tag
//
- changeInspector:sender
{
	id	cell;

	cell = [sender selectedCell];
	[self changeInspectorTo:[cell tag]];
	return self;
}

//
//	Change to specific Inspector
//
- changeInspectorTo:(insp_e)which
{
	id		newView;
	NSRect	r;
	id		cell;
	NSRect	f;
	
	if (which == currentInspectorType)
		return self;
	
	currentInspectorType = which;
	newView = [contentList objectAt:which];
	
	cell = [itemList objectAt:which];	// set PopUpButton title
	[popUpButton_i setTitle:[cell title]];
	
	[inspectorView_i replaceSubview:inspectorSubview_i with:newView];
	r = [inspectorView_i frame];
	inspectorSubview_i = newView;
	[inspectorSubview_i setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
	[inspectorSubview_i setFrameSize:NSMakeSize(r.size.width - 4, r.size.height - 4)];
	
	[inspectorSubview_i lockFocus];
	f = [inspectorSubview_i bounds];
	PSsetgray(NSLightGray);
	NSRectFill(f);
	[inspectorSubview_i unlockFocus];
	[inspectorView_i display];
	
	return self;
}

- (insp_e)getCurrentInspector
{
	return currentInspectorType;
}


@end
