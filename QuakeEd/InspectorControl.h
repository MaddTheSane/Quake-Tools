
#import <AppKit/AppKit.h>

#define MINIWINICON	"DoomEdIcon"

typedef enum
{
	i_project,
	i_textures,
	i_things,
	i_prefs,
	i_settings,
	i_output,
	i_help,
	i_end
} insp_e;

@class InspectorControl;
extern InspectorControl *inspcontrol_i;

@interface InspectorControl:NSObject
{
	IBOutlet NSView	*inspectorView_i;	// inspector view
	NSView	*inspectorSubview_i;	// inspector view's current subview (gets replaced)

	NSMutableArray	*contentList;		// List of contentviews (corresponds to
							// insp_e enum order)
	NSMutableArray	*windowList;			// List of Windows (corresponds to
							// insp_e enum order)

	id	obj_textures_i;		// TexturePalette object (for delegating)
	id	obj_genkeypair_i;	// GenKeyPair object

	IBOutlet NSPopUpButton	*popUpButton_i;		// PopUpList title button
	IBOutlet id	popUpMatrix_i;		// PopUpList matrix
	NSMutableArray	*itemList;			// List of popUp buttons
		
	insp_e	currentInspectorType;	// keep track of current inspector
	//
	//	Add id's here for new inspectors
	//  **NOTE: Make sure PopUpList has correct TAG value that
	//  corresponds to the enums above!
	
	// Windows
	IBOutlet NSWindow	*win_project_i;		// project
	IBOutlet NSWindow	*win_textures_i;		// textures
	IBOutlet NSWindow	*win_things_i;		// things
	IBOutlet NSWindow	*win_prefs_i;		// preferences
	IBOutlet NSWindow	*win_settings_i;		// project settings
	IBOutlet NSWindow	*win_output_i;		// bsp output
	IBOutlet NSWindow	*win_help_i;			// documentation
	
	// PopUpList objs
	IBOutlet id	itemProject_i;		// project
	IBOutlet id	itemTextures_i;		// textures
	IBOutlet id	itemThings_i;		// things
	IBOutlet id	itemPrefs_i;		// preferences
	IBOutlet id	itemSettings_i;		// project settings
	IBOutlet id	itemOutput_i;		// bsp output
	IBOutlet id	itemHelp_i;			// docs
}

- (void)awakeFromNib;
- (IBAction)changeInspector:sender;
- (void)changeInspectorTo:(insp_e)which;
- (insp_e)getCurrentInspector;

@end

@protocol InspectorControl <NSObject>
- (void)windowResized;
@end
