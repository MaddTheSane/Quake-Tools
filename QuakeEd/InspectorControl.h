
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

@class InspectorControl;
extern InspectorControl *inspcontrol_i;

@interface InspectorControl: NSObject
{
	IBOutlet NSView	*inspectorView_i;	// inspector view
	__unsafe_unretained NSView	*inspectorSubview_i;	// inspector view's current subview (gets replaced)

	NSArray	*contentList;		// List of contentviews (corresponds to
								// insp_e enum order)
	NSArray	*windowList;			// List of Windows (corresponds to
									// insp_e enum order)

	id	obj_textures_i;		// TexturePalette object (for delegating)
	id	obj_genkeypair_i;	// GenKeyPair object

	IBOutlet id	popUpButton_i;		// PopUpList title button
	IBOutlet id	popUpMatrix_i;		// PopUpList matrix
	NSArray	*itemList;			// List of popUp buttons
		
	insp_e	currentInspectorType;	// keep track of current inspector
	//
	//	Add id's here for new inspectors
	//  **NOTE: Make sure PopUpList has correct TAG value that
	//  corresponds to the enums above!
	
	// Windows
	IBOutlet NSWindow	*win_project_i;		// project
	IBOutlet NSWindow	*win_textures_i;	// textures
	IBOutlet NSWindow	*win_things_i;		// things
	IBOutlet NSWindow	*win_prefs_i;		// preferences
	IBOutlet NSWindow	*win_settings_i;		// project settings
	IBOutlet NSWindow	*win_output_i;		// bsp output
	IBOutlet NSWindow	*win_help_i;			// documentation
	
	// PopUpList objs
	IBOutlet NSPopUpButton *itemProject_i;		// project
	IBOutlet NSPopUpButton *itemTextures_i;		// textures
	IBOutlet NSPopUpButton *itemThings_i;		// things
	IBOutlet NSPopUpButton *itemPrefs_i;		// preferences
	IBOutlet NSPopUpButton *itemSettings_i;		// project settings
	IBOutlet NSPopUpButton *itemOutput_i;		// bsp output
	IBOutlet NSPopUpButton *itemHelp_i;			// docs
}

- (void)awakeFromNib;
- (IBAction)changeInspector:(id)sender;
@property (setter=changeInspectorTo:, getter=getCurrentInspector, nonatomic) insp_e inspector;

@end

@protocol InspectorControl <NSObject>
- (void)windowResized;
@end
