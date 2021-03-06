
#import "qedefs.h"

id	things_i;

@implementation Things

- init
{
	self = [super init];

	things_i = self;
	lastSelected = 0;
	
	return self;
}

//
//	Load the TEXT object with the entity comment
//
- (void)loadEntityComment:(id)obj
{
	[entity_comment_i replaceCharactersInRange:NSMakeRange(0, entity_comment_i.string.length) withString:@([obj comments])];
}


- (void)initEntities
{	
	NSString	*path;

	path = @([project_i getProgDirectory]);

	[prog_path_i setStringValue: path];
	
	[[EntityClassList alloc] initForSourceDirectory: path];

	[self loadEntityComment:[entity_classes_i objectAtIndex:lastSelected]];
	[entity_browser_i loadColumnZero];
	[[entity_browser_i matrixInColumn:0] selectCellAtRow:lastSelected column:0];

	[entity_browser_i setDoubleAction: @selector(doubleClickEntity:)];
}

- (IBAction)selectEntity: sender
{
	id		matr;
	
	matr = [sender matrixInColumn: 0];
	lastSelected = [matr selectedRow];
	[self loadEntityComment:[entity_classes_i objectAtIndex:lastSelected]];
	[quakeed_i makeFirstResponder: quakeed_i];
}

- (IBAction)doubleClickEntity: sender
{
	[map_i makeEntity: sender];
	[quakeed_i makeFirstResponder: quakeed_i];
}

- (NSString *)spawnName
{
	return [[entity_classes_i objectAtIndex:lastSelected] classname];
}


//
//	Flush entity classes & reload them!
//
- (IBAction)reloadEntityClasses: sender
{
	EntityClass *ent;
	NSString	*path;
	
	path = [prog_path_i stringValue];
	if (!path || path.length == 0)
	{
		path = [project_i getProgDirectory];
		[prog_path_i setStringValue: path];
	}
	
	//	Free all entity info in memory...
	//[entity_classes_i freeObjects];
	[entity_classes_i release];
	
	//	Now, RELOAD!
	entity_classes_i = [[EntityClassList alloc] initForSourceDirectory: path];

	lastSelected = 0;
	ent = [entity_classes_i objectAtIndex:lastSelected];
	[self loadEntityComment:[entity_classes_i objectAtIndex:lastSelected]];

	[entity_browser_i loadColumnZero];
	[[entity_browser_i matrixInColumn:0] selectCellAtRow:lastSelected column:0];

	[self newCurrentEntity];	// in case flags changed
}


- (void)selectClass: (NSString *)class
{
	id		classent;
		
	classent = [entity_classes_i classForName:class];
	if (!classent)
		return;
	lastSelected = [entity_classes_i indexOfObject: classent];
	
	if (lastSelected < 0)
		lastSelected = 0;
		
	[self loadEntityComment:classent];
	[[entity_browser_i matrixInColumn:0] selectCellAtRow:lastSelected column:0];
	[[entity_browser_i matrixInColumn:0] scrollCellToVisibleAtRow:lastSelected column:0];
}


- (void)newCurrentEntity
{
	id		ent, classent, cell;
	char	*classname;
	int		r, c;
	char	*flagname;
	int		flags;
	
	ent = [map_i currentEntity];
	classname = [ent valueForQKey: "classname"];
	if (ent != [map_i objectAtIndex: 0])
		[self selectClass: classname];	// don't reset for world
	classent = [entity_classes_i classForName:classname];
	flagname = [ent valueForQKey: "spawnflags"];
	if (!flagname)
		flags = 0;
	else
		flags = atoi(flagname);
	
	[flags_i setAutodisplay: NO];
	for (r=0 ; r<4 ; r++)
		for (c=0 ; c<3 ; c++)
		{
			cell = [flags_i cellAtRow:r column:c];
			if (c < 2)
			{
				flagname = [classent flagName: c*4 + r];
				[cell setTitle: @(flagname)];
			}
			[cell setIntValue: (flags & (1<< ((c*4)+r)) ) > 0];
		}
	[flags_i setAutodisplay: YES];
	[flags_i display];
	
//	[keyInput_i setStringValue: ""];
//	[valueInput_i setStringValue: ""];

	[keypairview_i calcViewSize];
	[keypairview_i display];
	
	[quakeed_i makeFirstResponder: quakeed_i];
}

//
//	Clicked in the Keypair view - set as selected
//
- (void)setSelectedKey:(epair_t *)ep;
{
	[keyInput_i setStringValue:@(ep->key)];
	[valueInput_i setStringValue:@(ep->value)];
	[valueInput_i	selectText:self];
}

- (void)clearInputs
{
//	[keyInput_i setStringValue: ""];
//	[valueInput_i setStringValue: ""];
	
	[quakeed_i makeFirstResponder: quakeed_i];
}

//
//	Action methods
//

-(IBAction)addPair:sender
{
	char	*key, *value;
	
	key = (char *)[keyInput_i stringValue];
	value = (char *)[valueInput_i stringValue];
	
	[ [map_i currentEntity] setKey: key toValue: value ];

	[keypairview_i calcViewSize];
	[keypairview_i display];

	[self clearInputs];
	[quakeed_i updateXY];
}

-(IBAction)delPair:sender
{
	[quakeed_i makeFirstResponder: quakeed_i];

	[ [map_i currentEntity] removeKeyPair: (char *)[keyInput_i stringValue] ];

	[keypairview_i calcViewSize];
	[keypairview_i display];

	[self clearInputs];

	[quakeed_i updateXY];
}


//
//	Set the key/value fields to "angle <button value>"
//
- (IBAction)setAngle:sender
{
	NSString	*title;
	NSString	*value;
	
	title = [[sender selectedCell] title];
	if (![title isEqualToString:@"Up"])
		value = @"-1";
	else if (![title isEqualToString:@"Dn"])
		value = @"-2";
	else
		value = title;
		//strcpy (value, title);
	
	[keyInput_i setStringValue:@"angle"];
	[valueInput_i setStringValue:value];
	[self addPair:NULL];
	
	[self clearInputs];

	[quakeed_i updateXY];
}

- (IBAction)setFlags:sender
{
	int		flags;
	int		r, c, i;
	id		cell;
	char	str[20];
	
	[self clearInputs];
	flags = 0;

	for (r=0 ; r<4 ; r++)
		for (c=0 ; c<3 ; c++)
		{
			cell = [flags_i cellAtRow:r column:c];
			i = ([cell intValue] > 0);
			flags |= (i<< ((c*4)+r));
		}
	
	if (!flags)
		[[map_i currentEntity] removeKeyPair: "spawnflags"];
	else
	{
		sprintf (str, "%i", flags);
		[[map_i currentEntity] setKey: "spawnflags" toValue: str];
	}
	
	[keypairview_i calcViewSize];
	[keypairview_i display];
}


//
//	Fill the Entity browser
//	(Delegate method - delegated in Interface Builder)
//
- (void)browser:(NSBrowser *)sender createRowsForColumn:(NSInteger)column inMatrix:(NSMatrix *)matrix;
{
	id			cell;
	NSInteger	max;
	int			i;
	id			object;
	
	max = [entity_classes_i count];
	i = 0;
	while(max--)
	{
		object = [entity_classes_i objectAtIndex:i];
		[matrix addRow];
		cell = [matrix cellAtRow:i++ column:0];
		[cell setStringValue:@([object classname])];
		[cell setLeaf:YES];
		[cell setLoaded:YES];
	}
}

@end
