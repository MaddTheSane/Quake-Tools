
#import "qedefs.h"

@implementation Dict

- (NSInteger)count
{
	return intDict.count;
}

- init
{
	if (self = [super init]) {
		intDict = [[NSMutableDictionary alloc] init];
	}
	return self;	
}

- (NSDictionary*)toNSDictionary
{
	return [NSDictionary dictionaryWithDictionary:intDict];
}

-(void)dealloc
{
	[intDict release];
	
	[super dealloc];
}

- (void)print
{
	for (NSString *key in intDict) {
		printf("%s : %s\n", key.UTF8String, intDict[key].UTF8String);
	}
}

/*
===========
copyWithZone

JDC
===========
*/
- copyWithZone:(NSZone *)zone
{
	Dict *new;
	
	new = [[Dict alloc] init];
	[new->intDict release];
	new->intDict = [intDict mutableCopy];
	
	return new;
}

- initFromFile:(FILE *)fp
{
	if (self = [self init]) {
		if (![self parseBraceBlock:fp]) {
			[self release];
			return nil;
		}
	};
	return self;
}

//===============================================
//
//	Dictionary pair functions
//
//===============================================

//
//	Write a { } block out to a FILE*
//
- (void)writeBlockTo:(FILE *)fp
{
	fprintf(fp,"{\n");
	for (NSString *key in intDict) {
		fprintf(fp,"\t{\"%s\"\t\"%s\"}\n",key.UTF8String,intDict[key].UTF8String);
	}
	fprintf(fp,"}\n");
}

//
//	Write a single { } block out
//
- (BOOL)writeFile:(NSString *)path
{
	FILE	*fp;
	
	fp = fopen(path.fileSystemRepresentation,"w+t");
	if (fp != NULL)
	{
		printf("Writing dictionary file %s.\n",path.UTF8String);
		fprintf(fp,"// QE_Project file %s\n",path.UTF8String);
		[self writeBlockTo:fp];
		fclose(fp);
	}
	else
	{
		printf("Error writing %s!\n",path.UTF8String);
		return NO;
	}

	return YES;
}

//===============================================
//
//	Utility methods
//
//===============================================

//
//	Find a keyword in storage
//	Returns * to dict_t, otherwise NULL
//
- (dict_t *) findKeyword:(NSString *)key
{
#if 0
	int		max;
	int		i;
	dict_t	*d;
	
	max = [self count];
	for (i = 0;i < max;i++)
	{
		d = [self elementAt:i];
		if (!strcmp(d->key,key))
			return d;
	}
	
	return NULL;
#else
	return NULL;
#endif
}

//
//	Change a keyword's string
//
- (void)changeStringFor:(NSString *)key to:(NSString *)value
{
	[intDict setValue:value forKey:key];
}

- (BOOL)containsObjectForKey:(NSString*)key
{
	return [intDict objectForKey:key] != nil;
}

//
//	Search for keyword, return the string *
//
- (NSString *)getStringFor:(NSString *)name
{
	return [intDict objectForKey:name] ?: @"";
}

//
//	Search for keyword, return the value
//
- (unsigned int)getValueFor:(NSString *)name
{
	NSString *n = [self getStringFor:name];
	return n.intValue;
}

//
//	Return # of units in keyword's value
//
- (int) getValueUnits:(NSString *)key
{
	id		temp;
	int		count;
	
	temp = [self parseMultipleFrom:key];
	count = [temp count];
	
	return count;
}

+ (NSString*)convertArrayToString:(NSArray<NSString*>*)list
{
	return [list componentsJoinedByString:@"\t"];
}

//
//	Convert List to string
//
- (NSString *)convertListToString:(id)list
{
	int		i;
	int		max;
	char	tempstr[4096];
	char	*s;
	char	*newstr;
	
	max = [list count];
	tempstr[0] = 0;
	for (i = 0;i < max;i++)
	{
		s = [list elementAt:i];
		strcat(tempstr,s);
		strcat(tempstr,"  ");
	}
	newstr = malloc(strlen(tempstr)+1);
	strcpy(newstr,tempstr);
	
	return @(newstr);
}

//
// JDC: I wrote this to simplify removing vectors
//
- (void)removeKeyword:(NSString *)key
{
	[intDict removeObjectForKey:key];
}

//
//	Delete string from keyword's value
//
- (BOOL)delString:(NSString *)string fromValue:(NSString *)key
{
	NSString *hi = [intDict objectForKey:key];
	if (!hi) {
		return NO;
	}
	NSMutableArray *arr = [[hi componentsSeparatedByString:@"\t"] mutableCopy];
	[arr removeObject:string];
	
	[intDict setObject:[arr componentsJoinedByString:@"\t"] forKey:key];
	[arr release];
	
	return YES;
}

//
//	Add string to keyword's value
//
- (BOOL)addString:(NSString *)string toValue:(NSString *)key
{
	NSString *const spacing = @"\t";
	NSMutableString *hi = [[intDict objectForKey:key] mutableCopy];
	if (!hi) {
		return NO;
	}
	
	[hi appendString:spacing];
	[hi appendString:string];
	[intDict setObject:[NSString stringWithString:hi] forKey:key];
	[hi release];
	
	return YES;
}

//===============================================
//
//	Use these for multiple parameters in a keyword value
//
//===============================================
const char	*searchStr;
char	item[4096];

- (void)setupMultiple:(NSString *)value
{
	searchStr = value.UTF8String;
}

- (NSString *)getNextParameter
{
	char	*s;
	
	if (!searchStr)
		return NULL;
	strcpy(item,searchStr);
	s = FindWhitespcInBuffer(item);	
	if (!*s)
		searchStr = NULL;
	else
	{
		*s = 0;
		searchStr = FindNonwhitespcInBuffer(s+1);
	}
	return @(item);
}

//
//	Parses a keyvalue string & returns a Storage full of those items
//
- (id) parseMultipleFrom:(NSString *)key
{
	#define	ITEMSIZE	128
	NSMutableArray	*stuff;
	NSString	*string;
	NSString	*s;
	
	s = [self getStringFor:key];
	if (s == NULL)
		return NULL;
		
	stuff = [[NSMutableArray alloc] init];
			
	[self setupMultiple:s];
	while((s = [self getNextParameter]))
	{
		string = s;
		[stuff addObject:string];
	}
	
	return [stuff autorelease];
}

//===============================================
//
//	Dictionary pair parsing
//
//===============================================

//
//	parse all keyword/value pairs within { } 's
//
- (BOOL) parseBraceBlock:(FILE *)fp
{
	int		c;
	dict_t	pair;
	char	string[1024];
	
	c = FindBrace(fp);
	if (c == -1) {
		return NO;
	}
	
	while((c = FindBrace(fp)) != '}')
	{
		if (c == -1)
			return NO;
//		c = FindNonwhitespc(fp);
//		if (c == -1)
//			return NULL;
//		CopyUntilWhitespc(fp,string);

// JDC: fixed to allow quoted keys
		c = FindNonwhitespc(fp);
		if (c == -1) {
			return NO;
		}
		c = fgetc(fp);
		if ( c == '\"') {
			CopyUntilQuote(fp,string);
		} else {
			ungetc (c,fp);
			CopyUntilWhitespc(fp,string);
		}

		pair.key = malloc(strlen(string)+1);
		strcpy(pair.key,string);
		
		c = FindQuote(fp);
		CopyUntilQuote(fp,string);
		pair.value = malloc(strlen(string)+1);
		strcpy(pair.value,string);
		
		[self addElement:&pair];
		c = FindBrace(fp);
	}
	
	return YES;
}

- (void)addElement:(dict_t*)elem
{
	[intDict setObject:@(elem->value) forKey:@(elem->key)];
	free(elem->key); free(elem->value);
}

@end

//===============================================
//
//	C routines for string parsing
//
//===============================================
int	GetNextChar(FILE *fp)
{
	int		c;
	int		c2;
	
	c = getc(fp);
	if (c == EOF)
		return -1;
	if (c == '/')		// parse comments
	{
		c2 = getc(fp);
		if (c2 == '/')
		{
			while((c2 = getc(fp)) != '\n');
			c = getc(fp);
		}
		else
			ungetc(c2,fp);
	}
	return c;
}

void CopyUntilWhitespc(FILE *fp,char *buffer)
{
	int	count = 800;
	int	c;
	
	while(count--)
	{
		c = GetNextChar(fp);
		if (c == EOF)
			return;
		if (c <= ' ')
		{
			*buffer = 0;
			return;
		}
		*buffer++ = c;
	}
}

void CopyUntilQuote(FILE *fp,char *buffer)
{
	int	count = 800;
	int	c;
	
	while(count--)
	{
		c = GetNextChar(fp);
		if (c == EOF)
			return;
		if (c == '\"')
		{
			*buffer = 0;
			return;
		}
		*buffer++ = c;
	}
}

int FindBrace(FILE *fp)
{
	int	count = 800;
	int	c;
	
	while(count--)
	{
		c = GetNextChar(fp);
		if (c == EOF)
			return -1;
		if (c == '{' ||
			c == '}')
			return c;
	}
	return -1;
}

int FindQuote(FILE *fp)
{
	int	count = 800;
	int	c;
	
	while(count--)
	{
		c = GetNextChar(fp);
		if (c == EOF)
			return -1;
		if (c == '\"')
			return c;
	}
	return -1;
}

int FindWhitespc(FILE *fp)
{
	int	count = 800;
	int	c;
		
	while(count--)
	{
		c = GetNextChar(fp);
		if (c == EOF)
			return -1;
		if (c <= ' ')
		{
			ungetc(c,fp);
			return c;
		}
	}
	return -1;		
}

int FindNonwhitespc(FILE *fp)
{
	int	count = 800;
	int	c;
		
	while(count--)
	{
		c = GetNextChar(fp);
		if (c == EOF)
			return -1;
		if (c > ' ')
		{
			ungetc(c,fp);
			return c;
		}
	}
	return -1;
}

char *FindWhitespcInBuffer(char *buffer)
{
	int	count = 1000;
	char	*b = buffer;
	
	while(count--)
		if (*b <= ' ')
			return b;
		else
			b++;
	return NULL;		
}

char *FindNonwhitespcInBuffer(char *buffer)
{
	int	count = 1000;
	char	*b = buffer;
	
	while(count--)
		if (*b > ' ')
			return b;
		else
			b++;
	return NULL;
}
