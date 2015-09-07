
#import <AppKit/AppKit.h>

@class QuakeEd;

extern	QuakeEd *quakeed_i;

extern	BOOL	filter_light, filter_path, filter_entities;
extern	BOOL	filter_clip_brushes, filter_water_brushes, filter_world;

extern	UserPath	*upath;

extern	id	g_cmd_out_i;

double I_FloatTime (void);

void NopSound (void);

void qprintf (char *fmt, ...);		// prints text to cmd_out_i

@interface QuakeEd : NSWindow
{
	BOOL	dirty;
	char	filename[1024];		// full path with .map extension

// UI objects
        IBOutlet id		brushcount_i;
        IBOutlet id		entitycount_i;
        IBOutlet id		regionbutton_i;

        IBOutlet id		show_coordinates_i;
        IBOutlet id		show_names_i;

        IBOutlet id		filter_light_i;
        IBOutlet id		filter_path_i;
        IBOutlet id		filter_entities_i;
        IBOutlet id		filter_clip_i;
        IBOutlet id		filter_water_i;
        IBOutlet id		filter_world_i;
	
        IBOutlet id		cmd_in_i;		// text fields
        IBOutlet id		cmd_out_i;	
	
        IBOutlet id		xy_drawmode_i;	// passed over to xyview after init
}

- setDefaultFilename;
- (char *)currentFilename;

- updateAll;		// when a model has been changed
- updateCamera;		// when the camera has moved
- updateXY;
- updateZ;

- (IBAction)updateAll:sender;

- newinstance;		// force next flushwindow to clear all instance drawing
- redrawInstance;	// erase and redraw all instance now

- appDidInit:sender;
- appWillTerminate:sender;

- (IBAction)openProject:sender;

- (IBAction)textCommand: sender;

- (IBAction)applyRegion: sender;

- (BOOL)dirty;

- (IBAction)clear: sender;
- (IBAction)centerCamera: sender;
- (IBAction)centerZChecker: sender;

- (IBAction)changeXYLookUp: sender;

- (IBAction)setBrushRegion: sender;
- (IBAction)setXYRegion: sender;

- (IBAction)open: sender;
- (IBAction)save: sender;
- (IBAction)saveAs: sender;

- doOpen: (char *)fname;

- saveBSP:(char *)cmdline dialog:(BOOL)wt;

- (IBAction)BSP_Full: sender;
- (IBAction)BSP_FastVis: sender;
- (IBAction)BSP_NoVis: sender;
- (IBAction)BSP_relight: sender;
- (IBAction)BSP_stop: sender;
- (IBAction)BSP_entities: sender;

//
// UI querie for other objects
//
- (BOOL)showCoordinates;
- (BOOL)showNames;

@end

