
#import "qedefs.h"
#include <Carbon/Carbon.h>

QuakeEd *quakeed_i;
id	entclasses_i;

id	g_cmd_out_i;

BOOL	autodirty;
BOOL	filter_light, filter_path, filter_entities;
BOOL	filter_clip_brushes, filter_water_brushes, filter_world;

BOOL	running;

int bsppid;

#if 0
// example command strings

char	*fullviscmd = "rsh satan \"/LocalApps/qbsp $1 $2 ; /LocalApps/light $2 ; /LocalApps/vis $2\"";
char	*fastviscmd = "rsh satan \"/LocalApps/qbsp $1 $2 ; /LocalApps/light $2 ; /LocalApps/vis -fast $2\"";
char	*noviscmd = "rsh satan \"/LocalApps/qbsp $1 $2 ; /LocalApps/light $2\"";
char	*relightcmd = "rsh satan \"/LocalApps/light $2\"";
char	*leakcmd = "rsh satan \"/LocalApps/qbsp -mark -notjunc $1 $2\"";
#endif

void NopSound (void)
{
	NSBeep ();
}

UserPath	*upath;


void My_Malloc_Error (int code)
{
// recursive toast	Error ("Malloc error: %i\n", code);
	write (1, "malloc error!\n", strlen("malloc error!\n")+1);
}

/*
===============
AutoSave

Every five minutes, save a modified map
===============
*/
void AutoSave(DPSTimedEntry tag, double now, void *userData)
{
// automatic backup
	if (autodirty)
	{
		autodirty = NO;
		[map_i writeMapFile: FN_AUTOSAVE useRegion: NO];
	}
	[map_i writeStats];
}


void DisplayCmdOutput (void)
{
	char	*buffer;

	LoadFile (FN_CMDOUT, (void **)&buffer);
	unlink (FN_CMDOUT);
	[project_i addToOutput:buffer];
	free (buffer);

	if ([preferences_i getShowBSP])
		[inspcontrol_i changeInspectorTo:i_output];

	[preferences_i playBspSound];		
	
	NXPing ();
}

/*
===============
CheckCmdDone

See if the BSP is done
===============
*/
DPSTimedEntry	cmdte;
void CheckCmdDone(DPSTimedEntry tag, double now, void *userData)
{
    union wait statusp;
    struct rusage rusage;
	
	if (!wait4(bsppid, &statusp, WNOHANG, &rusage))
		return;
	DisplayCmdOutput ();
	bsppid = 0;
	DPSRemoveTimedEntry( cmdte );	
}

//============================================================================

@implementation QuakeEd

/*
===============
init
===============
*/
-(instancetype)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)backingType defer:(BOOL)flag
{
	if (self = [super initWithContentRect:contentRect styleMask:aStyle backing:backingType defer:flag]) {

	[self addToEventMask:
		NSRightMouseDraggedMask|NSLeftMouseDraggedMask];	
	
    malloc_error(My_Malloc_Error);
	
	quakeed_i = self;
	dirty = autodirty = NO;

	DPSAddTimedEntry(5*60, AutoSave, self, NX_BASETHRESHOLD);

	upath = newUserPath ();
	}
	
	return self;
}

- (void)setDefaultFilename
{	
	strcpy (filename, FN_TEMPSAVE);
	[self setTitleAsFilename:filename];
}


- (BOOL)dirty
{
	return dirty;
}

/*
===============================================================================

				DISPLAY UPDATING (handles both camera and XYView)

===============================================================================
*/

BOOL	updateinflight;

BOOL	clearinstance;

BOOL	updatexy;
BOOL	updatez;
BOOL	updatecamera;

void postappdefined (void)
{
	NSEvent *ev;

	if (updateinflight)
		return;
			
// post an event at the end of the que
	ev.type = NSApplicationDefined;
	if (DPSPostEvent(&ev, 0) == -1)
		printf ("WARNING: DPSPostEvent: full\n");
//printf ("posted\n");
	updateinflight = YES;
}


int	c_updateall;
- (void)updateAll			// when a model has been changed
{
	updatecamera = updatexy = updatez = YES;
	c_updateall++;
	postappdefined ();
}

- (void)updateAll:sender
{
	[self updateAll];
}

- (void)updateCamera		// when the camera has moved
{
	updatecamera = YES;
	clearinstance = YES;
	
	postappdefined ();
}

- (void)updateXY
{
	updatexy = YES;
	postappdefined ();
}

- (void)updateZ
{
	updatez = YES;
	postappdefined ();
}


- (void)newinstance
{
	clearinstance = YES;
}

- (void)redrawInstance
{
	clearinstance = YES;
	[self flushWindow];
}

/*
===============
flushWindow

instance draw the brush after each flush
===============
*/
-(void)flushWindow
{
	[super flushWindow];
	
	if (!running || in_error)
		return;		// don't lock focus before nib is finished loading
		
	if (_flushDisabled)
		return;
		
	[cameraview_i lockFocus];	
	if (clearinstance)
	{
		PSnewinstance ();
		clearinstance = NO;
	}

	PSsetinstance (1);
	linestart (0,0,0);
	[map_i makeSelectedPerform: @selector(CameraDrawSelf)];
	[clipper_i cameraDrawSelf];
	lineflush ();
	PSsetinstance (0);
	[cameraview_i unlockFocus];	

	[xyview_i lockFocus];
	PSsetinstance (1);
	linestart (0,0,0);
	[map_i makeSelectedPerform: @selector(XYDrawSelf)];
	lineflush ();
	[cameraview_i XYDrawSelf];
	[zview_i XYDrawSelf];
	[clipper_i XYDrawSelf];
	PSsetinstance (0);
	[xyview_i unlockFocus];

	[zview_i lockFocus];
	PSsetinstance (1);
	[map_i makeSelectedPerform: @selector(ZDrawSelf)];
	[cameraview_i ZDrawSelf];
	[clipper_i ZDrawSelf];
	PSsetinstance (0);
	[zview_i unlockFocus];
}


/*
==============================================================================

App delegate methods

==============================================================================
*/

- (void)applicationDefined:(NSEvent *)theEvent
{
	NSEvent		*ev, *evp;
	
	updateinflight = NO;

//printf ("serviced\n");
	
// update screen	
	evp = [NSApp peekNextEvent:-1 into:&ev];
	if (evp)
	{
		postappdefined();
		return;
	}

		
	[self disableFlushWindow];	

	if ([map_i count] != [entitycount_i intValue])
		[entitycount_i setIntValue: [map_i count]];
	if ([[map_i currentEntity] count] != [brushcount_i intValue])
		[brushcount_i setIntValue: [[map_i currentEntity] count]];
		
	if (updatecamera)
		[cameraview_i display];
	if (updatexy)
		[xyview_i display];
	if (updatez)
		[zview_i display];

	updatecamera = updatexy = updatez = NO;

	[self reenableFlushWindow];
	[self flushWindow];
	
//	NXPing ();
}

-(void)applicationDidFinishLaunching:(NSNotification *)notification
{
	NSArray<NSScreen*>	*screens = [NSScreen screens];
	NSInteger	screencount;
	
	running = YES;
	g_cmd_out_i = cmd_out_i;	// for qprintf

	[preferences_i	readDefaults];
	[project_i		initProject];

	[xyview_i setModeRadio: xy_drawmode_i];	// because xy view is inside
											// scrollview and can't be
											// connected directly in IB
	
	[self setFrameAutosaveName:@"EditorWinFrame"];
	[self clear: self];

// go to my second monitor
	if ([screens count] >= 2) {
		//[self moveTopLeftTo:0 : screens[1].screenBounds.size.height
		//screen:screens+1];
		[self constrainFrameRect:self.frame toScreen:screens[1]];
	}
	
	[self makeKeyAndOrderFront: self];

//[self doOpen: "/raid/quake/id1_/maps/amlev1.map"];	// DEBUG
	[map_i newMap];
		
	qprintf ("ready.");

//malloc_debug(-1);		// DEBUG
}

-(void)applicationWillTerminate:(NSNotification *)notification
{
	// FIXME: save dialog if dirty

}


//===========================================================================

- (IBAction)textCommand: sender
{
	NSString *t;
	
	t = [sender stringValue];
	
	if ([t isEqualToString:@"texname"]) {
		texturedef_t	*td;
		id				b;
		
		b = [map_i selectedBrush];
		if (!b) {
			qprintf ("nothing selected");
			return;
		}
		td = [b texturedef];
		qprintf (td->texture);
		return;
	} else
		qprintf ("Unknown command\n");
	return;
}


- (IBAction)openProject:sender
{
	[project_i	openProject];
}


- (IBAction)clear: sender
{	
	[map_i newMap];

	[self updateAll];
	[regionbutton_i setIntValue: 0];
	[self setDefaultFilename];
}


- (IBAction)centerCamera: sender
{
	NSRect	sbounds;
	sbounds = [xyview_i superview].bounds;
	
	sbounds.origin.x += sbounds.size.width/2;
	sbounds.origin.y += sbounds.size.height/2;
	
	[cameraview_i setXYOrigin: sbounds.origin];
	[self updateAll];
}

- (IBAction)centerZChecker: sender
{
	NSRect	sbounds = xyview_i.superview.bounds;
	
	sbounds.origin.x += sbounds.size.width/2;
	sbounds.origin.y += sbounds.size.height/2;
	
	[zview_i setPoint: &sbounds.origin];
	[self updateAll];
}

- (IBAction)changeXYLookUp: sender
{
	if ([sender intValue])
	{
		xy_viewnormal[2] = 1;
	}
	else
	{
		xy_viewnormal[2] = -1;
	}
	[self updateAll];
}

/*
==============================================================================

REGION MODIFICATION

==============================================================================
*/


/*
==================
applyRegion:
==================
*/
- (IBAction)applyRegion: sender
{
	filter_clip_brushes = [filter_clip_i intValue];
	filter_water_brushes = [filter_water_i intValue];
	filter_light = [filter_light_i intValue];
	filter_path = [filter_path_i intValue];
	filter_entities = [filter_entities_i intValue];
	filter_world = [filter_world_i intValue];

	if (![regionbutton_i intValue])
	{
		region_min[0] = region_min[1] = region_min[2] = -9999;
		region_max[0] = region_max[1] = region_max[2] = 9999;
	}

	[map_i makeGlobalPerform: @selector(newRegion)];
	
	[self updateAll];
}

- (IBAction)setBrushRegion: sender
{
	id		b;

// get the bounds of the current selection
	
	if ([map_i numSelected] != 1)
	{
		qprintf ("must have a single brush selected");
		return;
	} 

	b = [map_i selectedBrush];
	[b getMins: region_min maxs: region_max];
	[b remove];

// turn region on
	[regionbutton_i setIntValue: 1];
	[self applyRegion: self];
}

- (IBAction)setXYRegion: sender
{
	NSRect	bounds = xyview_i.superview.bounds;
	
// get xy size

	region_min[0] = bounds.origin.x;
	region_min[1] = bounds.origin.y;
	region_min[2] = -99999;
	region_max[0] = bounds.origin.x + bounds.size.width;
	region_max[1] = bounds.origin.y + bounds.size.height;
	region_max[2] = 99999;
	
// turn region on
	[regionbutton_i setIntValue: 1];
	[self applyRegion: self];
}

//
// UI querie for other objects
//
- (BOOL)showCoordinates
{
	return [show_coordinates_i intValue];
}

- (BOOL)showNames
{
	return [show_names_i intValue];
}


/*
==============================================================================

BSP PROCESSING

==============================================================================
*/

void ExpandCommand (char *in, char *out, char *src, char *dest)
{
	while (*in)
	{
		if (in[0] == '$')
		{
			if (in[1] == '1')
			{
				strcpy (out, src);
				out += strlen(src);
			}
			else if (in[1] == '2')
			{
				strcpy (out, dest);
				out += strlen(dest);
			}
			in += 2;			
			continue;
		}
		*out++ = *in++;
	}
	*out = 0;
}


/*
=============
saveBSP
=============
*/
- saveBSP:(char *)cmdline dialog:(BOOL)wt
{
	char	expandedcmd[1024];
	char	mappath[1024];
	char	bsppath[1024];
	int		oldLightFilter;
	int		oldPathFilter;
	char	*destdir;
	
	if (bsppid)
	{
		NSBeep();
		return self;
	}

//
// turn off the filters so all entities get saved
//
	oldLightFilter = [filter_light_i intValue];
	oldPathFilter = [filter_path_i intValue];
	[filter_light_i setIntValue:0];
	[filter_path_i setIntValue:0];
	[self applyRegion: self];
	
	if ([regionbutton_i intValue])
	{
		strcpy (mappath, filename);
		StripExtension (mappath);
		strcat (mappath, ".reg");
		[map_i writeMapFile: mappath useRegion: YES];
		wt = YES;		// allways pop the dialog on region ops
	}
	else
		strcpy (mappath, filename);
		
// save the entire thing, just in case there is a problem
	[self save: self];

	[filter_light_i setIntValue:oldLightFilter];
	[filter_path_i setIntValue:oldPathFilter];
	[self applyRegion: self];

//
// write the command to the bsp host
//	
	destdir = [project_i getFinalMapDirectory];

	strcpy (bsppath, destdir);
	strcat (bsppath, "/");
	ExtractFileBase (mappath, bsppath + strlen(bsppath));
	strcat (bsppath, ".bsp");
	
	ExpandCommand (cmdline, expandedcmd, mappath, bsppath);

	strcat (expandedcmd, " > ");
	strcat (expandedcmd, FN_CMDOUT);
	strcat (expandedcmd, "\n");
	printf ("system: %s", expandedcmd);

	[project_i addToOutput: "\n\n========= BUSY =========\n\n"];
	[project_i addToOutput: expandedcmd];

	if ([preferences_i getShowBSP])
		[inspcontrol_i changeInspectorTo:i_output];
	
	if (wt)
	{
		id		panel;
		
		panel = NXGetAlertPanel("BSP In Progress",expandedcmd,NULL,NULL,NULL);
		[panel makeKeyAndOrderFront:NULL];
		system(expandedcmd);
		NXFreeAlertPanel(panel);
		[self makeKeyAndOrderFront:NULL];
		DisplayCmdOutput ();
	}
	else
	{
		cmdte = DPSAddTimedEntry(1, CheckCmdDone, self, NX_BASETHRESHOLD);
		if (! (bsppid = fork ()) )
		{
			system (expandedcmd);
			exit (0);
		}
	}
	
	return self;
}


- (IBAction)BSP_Full: sender
{
	[self saveBSP:[project_i getFullVisCmd] dialog: NO];
}

- (IBAction)BSP_FastVis: sender
{
	[self saveBSP:[project_i getFastVisCmd] dialog: NO];
}

- (IBAction)BSP_NoVis: sender
{
	[self saveBSP:[project_i getNoVisCmd] dialog: NO];
}

- (IBAction)BSP_relight: sender
{
	[self saveBSP:[project_i getRelightCmd] dialog: NO];
}

- (IBAction)BSP_entities: sender
{
	[self saveBSP:[project_i getEntitiesCmd] dialog: NO];
}

- (IBAction)BSP_stop: sender
{
	if (!bsppid)
	{
		NSBeep();
		return;
	}
	
	kill (bsppid, 9);
	CheckCmdDone (cmdte, 0, NULL);
	[project_i addToOutput: "\n\n========= STOPPED =========\n\n"];
}



/*
==============
doOpen:

Called by open or the project panel
==============
*/
- (void)doOpen: (const char *)fname;
{	
	strcpy (filename, fname);
	
	[map_i readMapFile:filename];
	
	[regionbutton_i setIntValue: 0];
	[self setTitleAsFilename:fname];
	[self updateAll];

	qprintf ("%s loaded\n", fname);
}


/*
==============
open
==============
*/
- (IBAction)open: sender;
{
	NSOpenPanel	*openpanel;

	openpanel = [NSOpenPanel openPanel];
	NSString *mapDir = @([project_i getMapDirectory]);
	openpanel.directoryURL = [NSURL fileURLWithPath:mapDir];
	openpanel.allowedFileTypes = @[@"map"];

	if ( [openpanel runModal] != NSFileHandlingPanelOKButton)
		return;

	[self doOpen: [[openpanel filename] fileSystemRepresentation]];
}


/*
==============
save:
==============
*/
- (IBAction)save: sender;
{
	char		backup[1024];

// force a name change if using tempname
	if (!strcmp (filename, FN_TEMPSAVE) ) {
		[self saveAs: self];
		return;
	}
	
	dirty = autodirty = NO;

	strcpy (backup, filename);
	StripExtension (backup);
	strcat (backup, ".bak");
	rename (filename, backup);		// copy old to .bak

	[map_i writeMapFile: filename useRegion: NO];
}


/*
==============
saveAs
==============
*/
- (IBAction)saveAs: sender;
{
	NSSavePanel	*panel_i;
	char		dir[1024];
	
	panel_i = [NSSavePanel savePanel];
	ExtractFileBase (filename, dir);
	panel_i.allowedFileTypes = @[@"map"];
	NSString *mapDir = @([project_i getMapDirectory]);
	panel_i.directoryURL = [NSURL fileURLWithPath:mapDir];
	if ( [panel_i runModal] != NSFileHandlingPanelOKButton)
		return;
	
	strcpy (filename, [[panel_i filename] fileSystemRepresentation]);
	
	[self setTitleAsFilename:filename];
	
	[self save: sender];
}


/*
===============================================================================

						OTHER METHODS

===============================================================================
*/


//
//	AJR - added this for Project info
//
- (const char *)currentFilename
{
	return filename;
}

- (IBAction)deselect: sender
{
	if ([clipper_i hide])	// first click hides clipper only
		[self updateAll];

	[map_i setCurrentEntity: [map_i objectAt: 0]];	// make world selected
	[map_i makeSelectedPerform: @selector(deselect)];
	[self updateAll];
	
	return;
}


/*
===============
keyDown
===============
*/

#define	KEY_RIGHTARROW		0xae
#define	KEY_LEFTARROW		0xac
#define	KEY_UPARROW			0xad
#define	KEY_DOWNARROW		0xaf

- (void)keyDown:(NSEvent *)theEvent
{
    int		ch;
	
// function keys
	switch (theEvent.keyCode)
	{
	case kVK_F2:	// F2
		[cameraview_i setDrawMode: dr_wire];
		qprintf ("wire draw mode");
		return;
	case kVK_F3:	// F3
		[cameraview_i setDrawMode: dr_flat];
		qprintf ("flat draw mode");
		return;
	case kVK_F4:	// F4
		[cameraview_i setDrawMode: dr_texture];
		qprintf ("texture draw mode");
		return;

	case kVK_F5:	// F5
		[xyview_i setDrawMode: dr_wire];
		qprintf ("wire draw mode");
		return;
	case kVK_F6:	// F6
		qprintf ("texture draw mode");
		return;
		
	case kVK_F8:	// F8
		[cameraview_i homeView: self];
		return;
		
	case kVK_F12:	// F12
		[map_i subtractSelection: self];
		return;

	case kVK_PageUp:	// page up
		[cameraview_i upFloor: self];
		return;
		
	case kVK_PageDown:	// page down
		[cameraview_i downFloor: self];
		return;
		
	case kVK_End:	// end
		[self deselect: self];
		return;
	}

// portable things
    ch = tolower([theEvent.charactersIgnoringModifiers characterAtIndex:0]);
		
	switch (ch)
	{
	case KEY_RIGHTARROW:
	case KEY_LEFTARROW:
	case KEY_UPARROW:
	case KEY_DOWNARROW:
	case 'a':
	case 'z':
	case 'd':
	case 'c':
	case '.':
	case ',':
		[cameraview_i _keyDown: theEvent];
		break;

	case 27:	// escape
		autodirty = dirty = YES;
		[self deselect: self];
		return;
		
	case 127:	// delete
		autodirty = dirty = YES;
		[map_i makeSelectedPerform: @selector(remove)];
		[clipper_i hide];
		[self updateAll];
		break;

	case '/':
		[clipper_i flipNormal];
		[self updateAll];
		break;
		
	case 13:	// enter
		[clipper_i carve];
		[self updateAll];
		qprintf ("carved brush");
		break;
		
	case ' ':
		[map_i cloneSelection: self];
		break;
		

//
// move selection keys
//		
	case '2':
		VectorCopy (vec3_origin, sb_translate);
		sb_translate[1] = -[xyview_i gridsize];
		[map_i makeSelectedPerform: @selector(translate)];
		[self updateAll];
		break;
	case '8':
		VectorCopy (vec3_origin, sb_translate);
		sb_translate[1] = [xyview_i gridsize];
		[map_i makeSelectedPerform: @selector(translate)];
		[self updateAll];
		break;

	case '4':
		VectorCopy (vec3_origin, sb_translate);
		sb_translate[0] = -[xyview_i gridsize];
		[map_i makeSelectedPerform: @selector(translate)];
		[self updateAll];
		break;
	case '6':
		VectorCopy (vec3_origin, sb_translate);
		sb_translate[0] = [xyview_i gridsize];
		[map_i makeSelectedPerform: @selector(translate)];
		[self updateAll];
		break;

	case '-':
		VectorCopy (vec3_origin, sb_translate);
		sb_translate[2] = -[xyview_i gridsize];
		[map_i makeSelectedPerform: @selector(translate)];
		[self updateAll];
		break;
	case '+':
		VectorCopy (vec3_origin, sb_translate);
		sb_translate[2] = [xyview_i gridsize];
		[map_i makeSelectedPerform: @selector(translate)];
		[self updateAll];
		break;

	default:
		qprintf ("undefined keypress");
		NopSound ();
		break;
	}
}


@end
