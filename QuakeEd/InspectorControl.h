
#import <AppKit/AppKit.h>

#define MINIWINICON	"DoomEdIcon"

typedef NS_ENUM(NSInteger, insp_e)
{
	i_project,
	i_textures,
	i_things,
	i_prefs,
	i_settings,
	i_output,
	i_help,
	i_end
};

extern	id		inspcontrol_i;

@interface InspectorControl: NSObject
{
	IBOutlet id	inspectorView_i;	// inspector view
	IBOutlet id	inspectorSubview_i;	// inspector view's current subview (gets replaced)

	IBOutlet id	contentList;		// List of contentviews (corresponds to
							// insp_e enum order)
	IBOutlet id	windowList;			// List of Windows (corresponds to
							// insp_e enum order)

	IBOutlet id	obj_textures_i;		// TexturePalette object (for delegating)
	IBOutlet id	obj_genkeypair_i;	// GenKeyPair object

	IBOutlet id	popUpButton_i;		// PopUpList title button
	IBOutlet id	popUpMatrix_i;		// PopUpList matrix
	IBOutlet id	itemList;			// List of popUp buttons
		
	insp_e	currentInspectorType;	// keep track of current inspector
	//
	//	Add id's here for new inspectors
	//  **NOTE: Make sure PopUpList has correct TAG value that
	//  corresponds to the enums above!
	
	// Windows
	IBOutlet id	win_project_i;		// project
	IBOutlet id	win_textures_i;		// textures
	IBOutlet id	win_things_i;		// things
	IBOutlet id	win_prefs_i;		// preferences
	IBOutlet id	win_settings_i;		// project settings
	IBOutlet id	win_output_i;		// bsp output
	IBOutlet id	win_help_i;			// documentation
	
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
- changeInspector:sender;
- changeInspectorTo:(insp_e)which;
- (insp_e)getCurrentInspector;

@end

@protocol InspectorControl
- windowResized;
@end
