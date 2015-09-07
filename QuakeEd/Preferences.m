
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
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	[defaults setFloat:value forKey:name];
}

void WriteNSStringDefault (NSString *name, NSString *value)
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	[defaults setValue:value forKey:name];
}


void WriteStringDefault (NSString *name, const char *value)
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	[defaults setValue:@(value) forKey:name];
}

//
//	Read in at start of program
//
- (void)readDefaults
{
	char *string;
	float	value;
	
	string = (char *)NXGetDefaultValue(DEFOWNER,"ProjectPath");
	[self setProjectPath: string];
	
	string = (char *)NXGetDefaultValue(DEFOWNER,"BspSoundPath");
	[self setBspSoundPath:string];

	value = _atoi((char *)NXGetDefaultValue(DEFOWNER,"ShowBSPOutput"));
	[self setShowBSP:value];

	value = _atoi((char *)NXGetDefaultValue(DEFOWNER,"OffsetBrushCopy"));
	[self setBrushOffset:value];

	value = _atoi((char *)NXGetDefaultValue(DEFOWNER,"StartWad"));
	[self setStartWad:value];

	value = _atof((char *)NXGetDefaultValue(DEFOWNER,"Xlight"));
	[self setXlight:value];

	value = _atof((char *)NXGetDefaultValue(DEFOWNER,"Ylight"));
	[self setYlight:value];

	value = _atof((char *)NXGetDefaultValue(DEFOWNER,"Zlight"));
	[self setZlight:value];
}

@synthesize projectPath = projectpath;
- (void)setProjectPath:(NSString *)path
{
	if (!path)
		path = @"";
	projectpath = [path copy];
	[startproject_i setStringValue: path];
	WriteNSStringDefault (@"ProjectPath", path);
}

- (IBAction)setCurrentProject:sender
{
	[startproject_i setStringValue: [project_i currentProjectFile]];
	[self UIChanged: self];
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
	NSOpenPanel	*panel;
	NSInteger	rtn;
	NSString *path;
	NSString *file;
	
	panel = [NSOpenPanel openPanel];
	panel.allowedFileTypes = [NSSound soundUnfilteredTypes];

	path = [bspSound stringByDeletingLastPathComponent];
	file = [bspSound lastPathComponent];
	panel.directoryURL = [NSURL fileURLWithPath:path];
	panel.nameFieldStringValue = file;
	
	rtn = [panel runModal];

	if (rtn) {
		NSString *fullFile = [[panel URL] path];
		[self setBspSoundPath:fullFile];
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
	bspSound = [path copy];
	
	if (bspSound_i)
		[bspSound_i free];
	bspSound_i = [[NSSound alloc] initWithContentsOfFile:bspSound byReference:NO];
	if (!bspSound_i)
	{
		bspSound = [@"Funk" retain];
		bspSound_i = [[NSSound soundNamed:@"Funk"] retain];
	}
	
	[bspSoundField_i setStringValue:bspSound];
	
	WriteNSStringDefault (@"BspSoundPath", bspSound);
}

//===============================================
//	Show BSP Output management
//===============================================

//
//	Set the state
//
- (void)setShowBSP:(BOOL)state
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	showBSP = state;
	[showBSP_i setIntValue:state];
	[defaults setBool:state forKey:@"ShowBSPOutput"];
}

//
//	Get the state
//
@synthesize showBSP;
@synthesize brushOffset;

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
}
- (void)setYlight:(float)value
{
	ylight = value;
	if (ylight < 0.25 || ylight > 1)
		ylight = 0.75;
	lightaxis[2] = ylight;
	[ylight_i setFloatValue:ylight];
	WriteNumericDefault (@"Ylight", ylight);
}
- (void)setZlight:(float)value
{
	zlight = value;
	if (zlight < 0.25 || zlight > 1)
		zlight = 1;
	lightaxis[0] = zlight;
	[zlight_i setFloatValue:zlight];
	WriteNumericDefault (@"Zlight", zlight);
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
-(IBAction)UIChanged: sender
{
	qprintf ("defaults updated");
	
	[self setProjectPath: [startproject_i stringValue]];
	[self setBspSoundPath: [bspSoundField_i stringValue]];
	[self setShowBSP: [showBSP_i intValue]];
	[self setBrushOffset: [brushOffset_i intValue]];
	[self setStartWad: [startwad_i selectedRow]];
	[self setXlight: [xlight_i floatValue]];
	[self setYlight: [ylight_i floatValue]];
	[self setZlight: [zlight_i floatValue]];

	[map_i makeGlobalPerform: @selector(flushTextures)];
	[quakeed_i updateAll];
}


@end
