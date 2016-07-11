
#import "qedefs.h"

@implementation DictList

//
//	Read in variable # of objects from FILE *
//
- initListFromFile:(FILE *)fp
{
	if (self = [super init]) {
	Dict	*d;
	do {
		d = [[Dict alloc] initFromFile:fp];
		if (d != NULL)
			[intList addObject:d];
		[d release];
	} while(d != NULL);
		intList = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[intList release];
	
	[super dealloc];
}

//
//	Write out list file
//
- (void)writeListFile:(NSString *)filename
{
	FILE	*fp;
	int		i;
	Dict	*obj;
	
	fp = fopen(filename.fileSystemRepresentation, "w+t");
	if (fp == NULL)
		return;
		
	fprintf(fp,"// Object List written by QuakeEd\n");

	for (i = 0;i < intList.count;i++)
	{
		obj = [intList objectAtIndex:i];
		[obj writeBlockTo:fp];
	}
	fclose(fp);
}

//
//	Find the keyword in all the Dict objects
//
- (id) findDictKeyword:(NSString *)key
{
	for (Dict *dict in intList) {
		if ([dict containsObjectForKey:key]) {
			return dict;
		}
	}
	return nil;
}

@end
