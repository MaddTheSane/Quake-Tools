
extern	id	preferences_i;

extern	float		lightaxis[3];

// these are personal preferences saved in NeXT defaults, not project
// parameters saved in the quake.qe_project file

@interface Preferences:NSObject
{
	NSSound		*bspSound_i;			// actual sound object

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
	id	startproject_i;			// TextField	

	id	bspSoundField_i;		// TextField of bspSound	

	id	brushOffset_i;			// Brush Offset checkbox
	id	showBSP_i;				// Show BSP Output checkbox
	
	id	startwad_i;				// which wad to load at startup

	id	xlight_i;				// X-side lighting
	id	ylight_i;				// Y-side lighting
	id	zlight_i;				// Z-side lighting	
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
- (void)setXlight:(float)value;		// set Xlight value for CameraView
- (void)setYlight:(float)value;		// set Ylight value for CameraView
- (void)setZlight:(float)value;		// set Zlight value for CameraView

@property (nonatomic, copy) NSString *projectPath;
@property (nonatomic) BOOL showBSP;
@property (nonatomic) BOOL brushOffset;
@property (nonatomic) int startWad;
@property (nonatomic) float xLight;
@property (nonatomic) float yLight;
@property (nonatomic) float zLight;

//
// UI targets
//
- (IBAction)setBspSound:sender;			// use OpenPanel to select sound
- (IBAction)setCurrentProject:sender;		// make current roject the default
- (IBAction)UIChanged: sender;			// target for all checks and fields

//
// methods used by other objects to retreive defaults
//
- (void)playBspSound;

- (const char *)getProjectPath NS_RETURNS_INNER_POINTER;
- (int)getBrushOffset;			// get the state
- (int)getShowBSP;				// get the state

- (float)getXlight;				// get Xlight value
- (float)getYlight;				// get Ylight value
- (float)getZlight;				// get Zlight value

- (int)getStartWad;


@end
