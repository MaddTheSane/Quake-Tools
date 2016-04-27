//======================================
//
// QuakeEd Project Management
//
//======================================

#import "qedefs.h"
//#import "QuakeEd-Swift.h"

id	project_i;

@implementation Project

- (instancetype)init
{
	if (self = [super init]) {
		project_i = self;
	}

	return self;
}

//===========================================================
//
//	Project code
//
//===========================================================
- (void)initVars
{
	NSString	*s;
	
	s = [preferences_i getProjectPath];
	StripFilename(s);
	strcpy(path_basepath,s);
	
	strcpy(path_progdir,s);
	strcat(path_progdir,"/"SUBDIR_ENT);
	
	strcpy(path_mapdirectory,s);
	strcat(path_mapdirectory,"/"SUBDIR_MAPS);	// source dir

	strcpy(path_finalmapdir,s);
	strcat(path_finalmapdir,"/"SUBDIR_MAPS);	// dest dir
	
	[basepathinfo_i	setStringValue:s];		// in Project Inspector
	
	#if 0
	if ((s = [projectInfo getStringFor:BASEPATHKEY]))
	{
		strcpy(path_basepath,s);
		
		strcpy(path_progdir,s);
		strcat(path_progdir,"/"SUBDIR_ENT);
		
		strcpy(path_mapdirectory,s);
		strcat(path_mapdirectory,"/"SUBDIR_MAPS);	// source dir

		strcpy(path_finalmapdir,s);
		strcat(path_finalmapdir,"/"SUBDIR_MAPS);	// dest dir
		
		[basepathinfo_i	setStringValue:s];		// in Project Inspector
	}
	#endif
		
	if ((s = [projectInfo getStringFor:BSPFULLVIS]))
	{
		strcpy(string_fullvis,s);
		changeString('@','\"',string_fullvis);
	}
		
	if ((s = [projectInfo getStringFor:BSPFASTVIS]))
	{
		strcpy(string_fastvis,s);
		changeString('@','\"',string_fastvis);
	}
		
	if ((s = [projectInfo getStringFor:BSPNOVIS]))
	{
		strcpy(string_novis,s);
		changeString('@','\"',string_novis);
	}
		
	if ((s = [projectInfo getStringFor:BSPRELIGHT]))
	{
		strcpy(string_relight,s);
		changeString('@','\"',string_relight);
	}
		
	if ((s = [projectInfo getStringFor:BSPLEAKTEST]))
	{
		strcpy(string_leaktest,s);
		changeString('@','\"',string_leaktest);
	}

	if ((s = [projectInfo getStringFor:BSPENTITIES]))
	{
		strcpy(string_entities,s);
		changeString('@','\"', string_entities);
	}

	// Build list of wads	
	wadList = [projectInfo parseMultipleFrom:WADSKEY];

	//	Build list of maps & descriptions
	mapList = [projectInfo parseMultipleFrom:MAPNAMESKEY];
	descList = [projectInfo parseMultipleFrom:DESCKEY];
	[self changeChar:'_' to:' ' in:descList];
	
	[self initProjSettings];
}

//
//	Init Project Settings fields
//
- (void)initProjSettings
{
	[pis_basepath_i	setStringValue:path_basepath];
	[pis_fullvis_i	setStringValue:string_fullvis];
	[pis_fastvis_i	setStringValue:string_fastvis];
	[pis_novis_i	setStringValue:string_novis];
	[pis_relight_i	setStringValue:string_relight];
	[pis_leaktest_i	setStringValue:string_leaktest];
}

//
//	Add text to the BSP Output window
//
- (void)addToOutput:(char *)string
{
	int	end;
	
	end = [BSPoutput_i textLength];
	[BSPoutput_i setSel:end :end];
	[BSPoutput_i replaceSel:string];
	
	end = [BSPoutput_i textLength];
	[BSPoutput_i setSel:end :end];
	[BSPoutput_i scrollSelToVisible];
}

- (IBAction)clearBspOutput:sender
{
	[BSPoutput_i	selectAll:self];
	[BSPoutput_i	replaceSel:"\0"];
}

- (void)print
{
	[BSPoutput_i	printPSCode:self];
}


- (void)initProject
{
	[self parseProjectFile];
	if (projectInfo == NULL)
		return;
	[self initVars];
	[mapbrowse_i reuseColumns:YES];
	[mapbrowse_i loadColumnZero];
	[pis_wads_i reuseColumns:YES];
	[pis_wads_i loadColumnZero];

	[things_i		initEntities];
}

//
//	Change a character to another in a Storage list of strings
//
- (void)changeChar:(char)f to:(char)t in:(id)obj
{
	int	i;
	int	max;
	char	*string;

	max = [obj count];
	for (i = 0;i < max;i++)
	{
		string = [obj elementAt:i];
		changeString(f,t,string);
	}
}

//
//	Fill the QuakeEd Maps or wads browser
//	(Delegate method - delegated in Interface Builder)
//
- (void)browser:(NSBrowser *)sender createRowsForColumn:(NSInteger)column inMatrix:(NSMatrix *)matrix
{
	NSArray			*list;
	NSBrowserCell	*cell;
	NSInteger		max;
	NSString		*name;
	int				i;

	if (sender == mapbrowse_i)
		list = mapList;
	else if (sender == pis_wads_i)
		list = wadList;
	else
	{
		list = nil;
		Error ("Project: unknown browser to fill");
	}
	
	max = [list count];
	for (i = 0 ; i<max ; i++)
	{
		name = [list objectAtIndex:i];
		[matrix addRow];
		cell = [matrix cellAtRow:i column:0];
		[cell setStringValue:name];
		[cell setLeaf:YES];
		[cell setLoaded:YES];
	}
}

//
//	Clicked on a map name or description!
//
- (IBAction)clickedOnMap:sender
{
	id			matrix;
	NSInteger	row;
	char		fname[1024];
	id			panel;
	
	matrix = [sender matrixInColumn:0];
	row = [matrix selectedRow];
	sprintf(fname,"%s/%s.map",path_mapdirectory,
		(char *)[mapList elementAt:row]);
	
	panel = NSGetAlertPanel(@"Loading...",
		@"Loading map. Please wait.",NULL,NULL,NULL);
	[panel orderFront:NULL];

	[quakeed_i doOpen:fname];

	[panel performClose:NULL];
	//NXFreeAlertPanel(panel);
}


- setTextureWad: (char *)wf
{
	NSInteger	i, c;
	char	*name;
	
	qprintf ("loading %s", wf);

// set the row in the settings inspector wad browser
	c = [wadList count];
	for (i=0 ; i<c ; i++)
	{
		name = (char *)[wadList elementAt:i];
		if (!strcmp(name, wf))
		{
			[[pis_wads_i matrixInColumn:0] selectCellAt: i : 0];
			break;
		}
	}

// update the texture inspector
	[texturepalette_i initPaletteFromWadfile:wf ];
	[[map_i objectAt: 0] setKey:"wad" toValue: wf];
//	[inspcontrol_i changeInspectorTo:i_textures];

	[quakeed_i updateAll];

	return self;
}

//
//	Clicked on a wad name
//
- clickedOnWad:sender
{
	NSMatrix	*matrix;
	NSInteger	row;
	char	*name;
	
	matrix = [sender matrixInColumn:0];
	row = [matrix selectedRow];

	name = (char *)[wadList elementAt:row];
	[self setTextureWad: name];
	
	return self;
}


//
//	Read in the <name>.QE_Project file
//
- (void)parseProjectFile
{
	NSString	*path;
	int			rtn;
	
	path = [preferences_i getProjectPath];
	if (!path || access([path fileSystemRepresentation],0))
	{
		rtn = NSRunAlertPanel(@"Project Error!",
			@"A default project has not been found.\n"
			, @"Open Project", NULL, NULL);
		if ([self openProject] == NO)
			while (1)		// can't run without a project
				[NSApp terminate: self];
		return;
	}

	[self openProjectFile:[path fileSystemRepresentation]];
}

//
//	Loads and parses a project file
//
- (BOOL)openProjectFile:(const char *)path
{		
	FILE	*fp;
	struct	stat s;

	strcpy(path_projectinfo,path);

	projectInfo = NULL;
	fp = fopen(path,"r+t");
	if (fp == NULL)
		return NO;

	stat(path,&s);
	lastModified = s.st_mtime;

	projectInfo = [[QDict dictionaryFromFile:fp] retain];
	fclose(fp);
	
	return YES;
}

//- (BOOL)openProjectFileAtURL:(NSURL*)aURL error:(NSError**)error
//{
//
//}

- (const char *)currentProjectFile
{
	return path_projectinfo;
}

//
//	Open a project file
//
- (BOOL)openProject
{
	NSOpenPanel	*openpanel;
	NSInteger	rtn;
	
	openpanel = [NSOpenPanel openPanel];
	openpanel.allowsMultipleSelection = NO;
	openpanel.canChooseDirectories = NO;
	openpanel.allowedFileTypes = @[@"qpr"];
	rtn = [openpanel runModal];
	if (rtn == NSModalResponseOK) {
		NSURL *selURL = [openpanel URL];
		strcpy(path_projectinfo, [selURL fileSystemRepresentation]);
		return [self openProjectFile:[selURL fileSystemRepresentation]];
	}
	return NO;
}


//
//	Search for a string in a List of strings
//
- (int)searchForString:(char *)str in:(id)obj
{
	NSInteger	i;
	NSInteger	max;
	char	*s;

	max = [obj count];
	for (i = 0;i < max; i++)
	{
		s = (char *)[obj elementAt:i];
		if (!strcmp(s,str))
			return 1;
	}
	return 0;
}

- (char *)getMapDirectory
{
	return path_mapdirectory;
}

- (char *)getFinalMapDirectory
{
	return path_finalmapdir;
}

- (char *)getProgDirectory
{
	return path_progdir;
}


//
//	Return the WAD name for cmd-8
//
- (char *)getWAD8
{
	if (!path_wad8[0])
		return NULL;
	return path_wad8;
}

//
//	Return the WAD name for cmd-9
//
- (char *)getWAD9
{
	if (!path_wad9[0])
		return NULL;
	return path_wad9;
}

//
//	Return the WAD name for cmd-0
//
- (char *)getWAD0
{
	if (!path_wad0[0])
		return NULL;
	return path_wad0;
}

//
//	Return the FULLVIS cmd string
//
- (char *)getFullVisCmd
{
	if (!string_fullvis[0])
		return NULL;
	return string_fullvis;
}

//
//	Return the FASTVIS cmd string
//
- (char *)getFastVisCmd
{
	if (!string_fastvis[0])
		return NULL;
	return string_fastvis;
}

//
//	Return the NOVIS cmd string
//
- (char *)getNoVisCmd
{
	if (!string_novis[0])
		return NULL;
	return string_novis;
}

//
//	Return the RELIGHT cmd string
//
- (char *)getRelightCmd
{
	if (!string_relight[0])
		return NULL;
	return string_relight;
}

//
//	Return the LEAKTEST cmd string
//
- (char *)getLeaktestCmd
{
	if (!string_leaktest[0])
		return NULL;
	return string_leaktest;
}

- (char *)getEntitiesCmd
{
	if (!string_entities[0])
		return NULL;
	return string_entities;
}

@end

//====================================================
// C Functions
//====================================================

//
// Change a character to a different char in a string
//
void changeString(char cf,char ct,char *string)
{
	int	j;

	for (j = 0;j < strlen(string);j++)
		if (string[j] == cf)
			string[j] = ct;
}


