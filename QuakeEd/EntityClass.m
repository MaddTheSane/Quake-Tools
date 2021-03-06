
#import "qedefs.h"

@implementation EntityClass

/*

the classname, color triple, and bounding box are parsed out of comments
A ? size means take the exact brush size.

/*QUAKED <classname> (0 0 0) ?
/*QUAKED <classname> (0 0 0) (-8 -8 -8) (8 8 8)

Flag names can follow the size description:

/*QUAKED func_door (0 .5 .8) ? START_OPEN STONE_SOUND DOOR_DONT_LINK GOLD_KEY SILVER_KEY

*/
NSString	*debugname;
- initFromText: (char *)text
{
	char		*t;
	NSInteger	len;
	int			r, i;
	char		parms[256], *p;
	
	[super init];
	
	text += strlen("/*QUAKED ");
	
// grab the name
	text = COM_Parse (text);
	name = [@(com_token) retain];
	debugname = name;
	
// grab the color
	r = sscanf (text," (%f %f %f)", &color[0], &color[1], &color[2]);
	if (r != 3)
		return NULL;
	
	while (*text != ')')
	{
		if (!*text)
			return NULL;
		text++;
	}
	text++;
	
// get the size	
	text = COM_Parse (text);
	if (com_token[0] == '(')
	{	// parse the size as two vectors
		esize = esize_fixed;
		r = sscanf (text,"%f %f %f) (%f %f %f)", &mins[0], &mins[1], &mins[2], &maxs[0], &maxs[1], &maxs[2]);
		if (r != 6)
			return NULL;

		for (i=0 ; i<2 ; i++)
		{
			while (*text != ')')
			{
				if (!*text)
					return NULL;
				text++;
			}
			text++;
		}
	}
	else
	{	// use the brushes
		esize = esize_model;
	}
	
// get the flags
	

// copy to the first /n
	p = parms;
	while (*text && *text != '\n')
		*p++ = *text++;
	*p = 0;
	text++;
	
// any remaining words are parm flags
	p = parms;
	for (i=0 ; i<8 ; i++)
	{
		p = COM_Parse (p);
		if (!p)
			break;
		strcpy (flagnames[i], com_token);
	} 

// find the length until close comment
	for (t=text ; t[0] && !(t[0]=='*' && t[1]=='/') ; t++)
	;
	
// copy the comment block out
	len = t-text;
	comments = malloc (len+1);
	memcpy (comments, text, len);
	comments[len] = 0;
	
	return self;
}

@synthesize esize;
@synthesize classname = name;

- (float *)mins
{
	return mins;
}

- (float *)maxs
{
	return maxs;
}

- (float *)drawColor
{
	return color;
}

- (const char *)comments
{
	return comments;
}


- (const char *)flagName: (unsigned)flagnum
{
	if (flagnum >= MAX_FLAGS)
		Error ("EntityClass flagName: bad number");
	return flagnames[flagnum];
}

- (void)dealloc
{
	[name release];
	
	[super dealloc];
}

@end

//===========================================================================

@implementation EntityClassList

/*
=================
insertEC:
=================
*/
- (void)insertEC: ec
{
	NSString *name = [ec classname];
	for (NSInteger i=0 ; i<classList.count ; i++)
	{
		if ([name compare:[[classList objectAtIndex:i] classname]] == NSOrderedDescending)
		{
			
			[classList insertObject: ec atIndex:i];
			return;
		}
	}
	[classList addObject: ec];
}


/*
=================
scanFile
=================
*/
- (void)scanFile: (NSString *)filename
{
	ssize_t	size;
	char	*data;
	id		cl;
	int		i;
	NSString *fullPath = [source_path stringByAppendingPathComponent:filename];
	
	size = LoadFile (fullPath.fileSystemRepresentation, (void *)&data);
	
	for (i=0 ; i<size ; i++)
		if (!strncmp(data+i, "/*QUAKED",8))
		{
			cl = [[EntityClass alloc] initFromText: data+i];
			if (cl)
				[self insertEC: cl];
			else
				printf ("Error parsing: %s in %s\n",debugname.fileSystemRepresentation, filename.UTF8String);
		}
		
	free (data);
}


/*
=================
scanDirectory
=================
*/
- (void)scanDirectory
{
	int		count, i;
	struct direct **namelist, *ent;
	NSFileManager *fm = [NSFileManager defaultManager];
	
	[classList removeAllObjects];
	
     count = scandir(source_path.fileSystemRepresentation, &namelist, NULL, NULL);
	
	for (i=0 ; i<count ; i++)
	{
		ent = namelist[i];
		if (ent->d_namlen <= 3)
			continue;
		if (!strcmp (ent->d_name+ent->d_namlen-3,".qc"))
			[self scanFile: [fm stringWithFileSystemRepresentation:ent->d_name length:ent->d_namlen]];
	}
}

EntityClassList *entity_classes_i;

- (EntityClass*)objectAtIndex:(NSInteger)idx
{
	return [classList objectAtIndex:idx];
}

- (NSUInteger)indexOfObject:(EntityClass*)anObject;
{
	return [classList indexOfObject:anObject];
}

- initForSourceDirectory: (NSString *)path
{
	if (self = [super init]) {
		classList = [[NSMutableArray alloc] init];
		source_path = [path copy];
		[self scanDirectory];
		
		entity_classes_i = self;
		
		nullclass = [[EntityClass alloc] initFromText:
					 "/*QUAKED UNKNOWN_CLASS (0 0.5 0) ?"];
	}
	return self;
}

- (id)classForName: (NSString *)name
{
	for (EntityClass *o in classList) {
		if ([name isEqualToString:o.classname])
			return o;
	}
	
	return nullclass;
}

- (void)dealloc
{
	[classList release];
	[source_path release];
	
	[super dealloc];
}

@end
