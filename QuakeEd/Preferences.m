
#import "qedefs.h"

id	preferences_i;

#define	DEFOWNER	"QuakeEd2"

float		lightaxis[3] = {1, 0.6, 0.75};

@implementation Preferences

- init
{
	[super init];
	preferences_i = self;
	return self;
}

int _atoi (char *c)
{
	if (!c)
		return 0;
	return atoi(c);
}

int _atof (char *c)
{
	if (!c)
		return 0;
	return atof(c);
}

void WriteNumericDefault (NSString *name, float value)
{
	[[NSUserDefaults standardUserDefaults] setFloat:value forKey:name];
}
void WriteStringDefault (NSString *name, NSString *value)
{
	[[NSUserDefaults standardUserDefaults] setObject:value forKey:name];
}

//
//	Read in at start of program
//
- (void)readDefaults
{
	char *string;
	float	value;
	
#warning DefaultsConversion: This used to be a call to NXGetDefaultValue with the owner DEFOWNER.  If the owner was different from your applications name, you may need to modify this code.
	string = (char *)[[[NSUserDefaults standardUserDefaults] objectForKey:@"ProjectPath"] cString];
	[self setProjectPath: string];
	
#warning DefaultsConversion: This used to be a call to NXGetDefaultValue with the owner DEFOWNER.  If the owner was different from your applications name, you may need to modify this code.
	string = (char *)[[[NSUserDefaults standardUserDefaults] objectForKey:@"BspSoundPath"] cString];
	[self setBspSoundPath:string];

#warning DefaultsConversion: This used to be a call to NXGetDefaultValue with the owner DEFOWNER.  If the owner was different from your applications name, you may need to modify this code.
	value = _atoi((char *)[[[NSUserDefaults standardUserDefaults] objectForKey:@"ShowBSPOutput"] cString]);
	[self setShowBSP:value];

#warning DefaultsConversion: This used to be a call to NXGetDefaultValue with the owner DEFOWNER.  If the owner was different from your applications name, you may need to modify this code.
	value = _atoi((char *)[[[NSUserDefaults standardUserDefaults] objectForKey:@"OffsetBrushCopy"] cString]);
	[self setBrushOffset:value];

#warning DefaultsConversion: This used to be a call to NXGetDefaultValue with the owner DEFOWNER.  If the owner was different from your applications name, you may need to modify this code.
	value = _atoi((char *)[[[NSUserDefaults standardUserDefaults] objectForKey:@"StartWad"] cString]);
	[self setStartWad:value];

#warning DefaultsConversion: This used to be a call to NXGetDefaultValue with the owner DEFOWNER.  If the owner was different from your applications name, you may need to modify this code.
	value = _atof((char *)[[[NSUserDefaults standardUserDefaults] objectForKey:@"Xlight"] cString]);
	[self setXlight:value];

#warning DefaultsConversion: This used to be a call to NXGetDefaultValue with the owner DEFOWNER.  If the owner was different from your applications name, you may need to modify this code.
	value = _atof((char *)[[[NSUserDefaults standardUserDefaults] objectForKey:@"Ylight"] cString]);
	[self setYlight:value];

#warning DefaultsConversion: This used to be a call to NXGetDefaultValue with the owner DEFOWNER.  If the owner was different from your applications name, you may need to modify this code.
	value = _atof((char *)[[[NSUserDefaults standardUserDefaults] objectForKey:@"Zlight"] cString]);
	[self setZlight:value];
}

@synthesize projectPath=projectpath;
- (void)setProjectPath:(NSString *)path
{
	if (!path)
		path = @"";
	[projectpath autorelease];
	projectpath = [path copy];
	[startproject_i setStringValue:path];
	WriteStringDefault (@"ProjectPath", path);
}

- (IBAction)setCurrentProject:sender
{
	[startproject_i setStringValue:[NSString stringWithCString:[project_i currentProjectFile]]];
	[self UIChanged: self];
}

- (const char *)getProjectPath
{
	return projectpath.fileSystemRepresentation;
}


//
//===============================================
//	BSP sound stuff
//===============================================
//
//	Set the BSP sound using an OpenPanel
//
- (IBAction)setBspSound:sender
{
	id	panel;
	char	*types[]={"snd",NULL};
	int	rtn;
	char	**filename;
	char	path[1024], file[64];
	
#warning FactoryMethods: [OpenPanel openPanel] used to be [OpenPanel new].  Open panels are no longer shared.  'openPanel' returns a new, autoreleased open panel in the default configuration.  To maintain state, retain and reuse one open panel (or manually re-set the state each time.)
	panel = [NSOpenPanel openPanel];

	ExtractFilePath (bspSound, path);
	ExtractFileBase (bspSound, file);
	
#error StringConversion: Open panel types are now stored in an NSArray of NSStrings (used to use char**).  Change your variable declaration.
	rtn = [panel runModalForDirectory:[NSString stringWithCString:path] file:[NSString stringWithCString:file] types:types];

	if (rtn)
	{
#error StringConversion: filenames now returns an NSArray of NSStrings (used to return a NULL terminated array of char * strings).  Change your variable declaration.
#warning GeneralNamingConversion: 'filenames' now returns absolute paths
		filename = (char **)[panel filenames];
		strcpy(bspSound,[[panel directory] cString]);
		strcat(bspSound,"/");
		strcat(bspSound,filename[0]);
		[self setBspSoundPath:bspSound];
		[self playBspSound];
	}
}


//
//	Play the BSP sound
//
- (void)playBspSound
{
	[bspSound_i play];	
}


//
//	Set the bspSound path
//
- (void)setBspSoundPath:(NSString *)path
{
	if (!path)
		path = @"";
	[bspSound release];
	bspSound = [path copy];

	if (bspSound_i)
		[bspSound_i release];
	bspSound_i = [[NSSound alloc] initWithContentsOfFile:bspSound byReference:NO];
	if (!bspSound_i)
	{
		[bspSound release];
		bspSound = [@"/System/Library/Sounds/Funk.aiff" retain];
		bspSound_i = [[NSSound soundNamed:@"Funk"] retain];
	}

	[bspSoundField_i setStringValue:bspSound];
	
	[[NSUserDefaults standardUserDefaults] setValue:bspSound forKey:@"BspSoundPath"];
}

//===============================================
//	Show BSP Output management
//===============================================

//
//	Set the state
//
- (void)setShowBSP:(BOOL)state
{
	showBSP = state;
	[showBSP_i setIntValue:state];
	[[NSUserDefaults standardUserDefaults] setBool:showBSP forKey:@"ShowBSPOutput"];
}

//
//	Get the state
//
- (int)getShowBSP
{
	return showBSP;
}


//===============================================
//	"Offset Brush ..." management
//===============================================

//
//	Set the state
//
- (void)setBrushOffset:(BOOL)state
{
	brushOffset = state;
	[brushOffset_i setIntValue:state];
	WriteNumericDefault (@"OffsetBrushCopy", state);
}

//
//	Get the state
//
- (int)getBrushOffset
{
	return brushOffset;
}

@synthesize brushOffset=brushOffset;

//===============================================
//	StartWad
//===============================================

- (void)setStartWad:(int)value		// set start wad (0-2)
{
	startwad = value;
	if (startwad<0 || startwad>2)
		startwad = 0;
	
	[startwad_i selectCellAtRow:startwad column:0];

	WriteNumericDefault (@"StartWad", value);
}

@synthesize startWad=startwad;

- (int)getStartWad
{
	return startwad;
}


//===============================================
//	X,Y,Z light values
//===============================================
//
//	Set the state
//
- (void)setXlight:(float)value
{
	xlight = value;
	if (xlight < 0.25 || xlight > 1)
		xlight = 0.6;
	lightaxis[1] = xlight;
	[xlight_i setFloatValue:xlight];
	WriteNumericDefault (@"Xlight", xlight);
	return self;
}
- (void)setYlight:(float)value
{
	ylight = value;
	if (ylight < 0.25 || ylight > 1)
		ylight = 0.75;
	lightaxis[2] = ylight;
	[ylight_i setFloatValue:ylight];
	WriteNumericDefault (@"Ylight", ylight);
	return self;
}
- (void)setZlight:(float)value
{
	zlight = value;
	if (zlight < 0.25 || zlight > 1)
		zlight = 1;
	lightaxis[0] = zlight;
	[zlight_i setFloatValue:zlight];
	WriteNumericDefault (@"Zlight", zlight);
	return self;
}

//
//	Get the state
//
- (float)getXlight
{
	return [xlight_i floatValue];
}
- (float)getYlight
{
	return [ylight_i floatValue];
}
- (float)getZlight
{
	return [zlight_i floatValue];
}



/*
============
UIChanged

Grab all the current UI state
============
*/
-UIChanged: sender
{
	qprintf ("defaults updated");
	
	[self setProjectPath: (char *)[[startproject_i stringValue] cString]];
	[self setBspSoundPath: (char *)[[bspSoundField_i stringValue] cString]];
	[self setShowBSP: [showBSP_i intValue]];
	[self setBrushOffset: [brushOffset_i intValue]];
	[self setStartWad: [startwad_i selectedRow]];
	[self setXlight: [xlight_i floatValue]];
	[self setYlight: [ylight_i floatValue]];
	[self setZlight: [zlight_i floatValue]];

	[map_i makeGlobalPerform: @selector(flushTextures)];
	[quakeed_i updateAll];
		
	return self;
}


@end
