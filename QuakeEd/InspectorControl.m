
#import "qedefs.h"

// Add .h-files here for new inspectors
#import	"Things.h"
#import	"TexturePalette.h"
#import	"Preferences.h"

InspectorControl *inspcontrol_i;

@implementation InspectorControl
@synthesize inspector = currentInspectorType;

- (void)awakeFromNib
{
	[super awakeFromNib];
	inspcontrol_i = self;
		
	currentInspectorType = -1;
	
	NSMutableArray *tmpArr1 = [NSMutableArray arrayWithCapacity:7];
	NSMutableArray *tmpArr2 = [NSMutableArray arrayWithCapacity:7];
	NSMutableArray *tmpArr3 = [NSMutableArray arrayWithCapacity:7];

#define contentList tmpArr1
#define windowList tmpArr2
#define itemList tmpArr3
	//contentList = [[List alloc] init];
	//windowList = [[List alloc] init];
	//itemList = [[List alloc] init];

	// ADD NEW INSPECTORS HERE...

	[windowList addObject:win_project_i];
	[contentList addObject:[win_project_i contentView]];
	[itemProject_i setKeyEquivalent:@"1"];
	[itemList addObject:itemProject_i];

	[windowList addObject:win_textures_i];
	[contentList addObject:[win_textures_i contentView]];
	[itemTextures_i setKeyEquivalent:@"2"];
	[itemList addObject:itemTextures_i];

	[windowList addObject:win_things_i];
	[contentList addObject:[win_things_i contentView]];
	[itemThings_i setKeyEquivalent:@"3"];
	[itemList addObject:itemThings_i];
	
	[windowList addObject:win_prefs_i];
	[contentList addObject:[win_prefs_i contentView]];
	[itemPrefs_i setKeyEquivalent:@"4"];
	[itemList addObject:itemPrefs_i];

	[windowList addObject:win_settings_i];
	[contentList addObject:[win_settings_i contentView]];
	[itemSettings_i setKeyEquivalent:@"5"];
	[itemList addObject:itemSettings_i];

	[windowList addObject:win_output_i];
	[contentList addObject:[win_output_i contentView]];
	[itemOutput_i setKeyEquivalent:@"6"];
	[itemList addObject:itemOutput_i];

	[windowList addObject:win_help_i];
	[contentList addObject:[win_help_i contentView]];
	[itemHelp_i setKeyEquivalent:@"7"];
	[itemList addObject:itemHelp_i];
#undef contentList
#undef windowList
#undef itemList
	contentList = [tmpArr1 copy];
	windowList = [tmpArr2 copy];
	itemList = [tmpArr3 copy];

	// Setup inspector window with project subview first

	[inspectorView_i setAutoresizesSubviews:YES];

	inspectorSubview_i = [contentList objectAtIndex:i_project];
	[inspectorView_i addSubview:inspectorSubview_i];

	currentInspectorType = -1;
	[self changeInspectorTo:i_project];
}


//
//	Sent by the PopUpList in the Inspector
//	Each cell in the PopUpList must have the correct tag
//
- (IBAction)changeInspector:(id)sender
{
	id	cell;

	cell = [sender selectedCell];
	[self changeInspectorTo:[cell tag]];
}

//
//	Change to specific Inspector
//
- (void)changeInspectorTo:(insp_e)which
{
	id		newView;
	NSRect	r;
	id		cell;
	NSRect	f;
	
	if (which == currentInspectorType)
		return;
	
	currentInspectorType = which;
	newView = [contentList objectAtIndex:which];
	
	cell = [itemList objectAtIndex:which];	// set PopUpButton title
	[popUpButton_i setTitle:[cell title]];
	
	[inspectorView_i replaceSubview:inspectorSubview_i with:newView];
	r = inspectorView_i.frame;
	inspectorSubview_i = newView;
	[inspectorSubview_i setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
	[inspectorSubview_i setFrameSize:NSMakeSize(r.size.width - 4, r.size.height - 4)];
	
	[inspectorSubview_i lockFocus];
	
	f = inspectorSubview_i.bounds;
	[[NSColor lightGrayColor] set];
	NSRectFill(f);
	[inspectorSubview_i unlockFocus];
	[inspectorView_i display];
}


@end
