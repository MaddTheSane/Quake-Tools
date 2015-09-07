
extern	id	preferences_i;

extern	float		lightaxis[3];

// these are personal preferences saved in NeXT defaults, not project
// parameters saved in the quake.qe_project file

@interface Preferences: NSObject
{
	id		bspSound_i;			// actual sound object

// internal state
	NSString	*projectpath;
	NSString	*bspSound;
	
	BOOL	brushOffset;
	BOOL	showBSP;

	float	xlight;
	float	ylight;
	float	zlight;				// 0.0 - 1.0
	
	int		startwad;			// 0 - 2
	
// UI targets
	IBOutlet id	startproject_i;			// TextField

	IBOutlet id	bspSoundField_i;		// TextField of bspSound

	IBOutlet id	brushOffset_i;			// Brush Offset checkbox
	IBOutlet id	showBSP_i;				// Show BSP Output checkbox
	
	IBOutlet id	startwad_i;				// which wad to load at startup

	IBOutlet id	xlight_i;				// X-side lighting
	IBOutlet id	ylight_i;				// Y-side lighting
	IBOutlet id	zlight_i;				// Z-side lighting	
}

- (void)readDefaults;

//
// validate and set methods called by UI or defaults
//
- (void)setProjectPath:(NSString *)path;
- (void)setBspSoundPath:(NSString *)path;	// set the path of the soundfile externally
- (void)setShowBSP:(BOOL)state;		// set the state of ShowBSP
- (void)setBrushOffset:(BOOL)state;	// set the state of BrushOffset
- (void)setStartWad:(int)value;		// set start wad (0-2)
@property (nonatomic, getter=getXlight) float xlight;
@property (nonatomic, getter=getYlight) float ylight;
@property (nonatomic, getter=getZlight) float zlight;
- (void)setXlight:(float)value;		// set Xlight value for CameraView
- (void)setYlight:(float)value;		// set Ylight value for CameraView
- (void)setZlight:(float)value;		// set Zlight value for CameraView

//
// UI targets
//
- (IBAction)setBspSound:(id)sender;			// use OpenPanel to select sound
- (IBAction)setCurrentProject:(id)sender;		// make current roject the default
- (IBAction)UIChanged:(id) sender;			// target for all checks and fields

//
// methods used by other objects to retreive defaults
//
- (void)playBspSound;

- (NSString *)getProjectPath;
@property (nonatomic, getter=getBrushOffset) BOOL brushOffset;
@property (nonatomic, getter=getShowBSP) BOOL showBSP;
@property (nonatomic, getter=getProjectPath, copy) NSString *projectPath;
- (BOOL)getBrushOffset;			// get the state
- (BOOL)getShowBSP;				// get the state

- (float)getXlight;				// get Xlight value
- (float)getYlight;				// get Ylight value
- (float)getZlight;				// get Zlight value

- (int)getStartWad;


@end
