
#import "qedefs.h"

@implementation DictList

//
//	Read in variable # of objects from FILE *
//
- initListFromFile:(FILE *)fp
{
	Dict	*d;
	
	self = [super init];
	do {
		d = [[Dict alloc] initFromFile:fp];
		if (d != NULL)
			[self addObject:d];
		[d release];
	} while(d != NULL);
	
	return self;
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

	for (i = 0;i < maxElements;i++)
	{
		obj = [self objectAt:i];
		[obj writeBlockTo:fp];
	}
	fclose(fp);
}

//
//	Find the keyword in all the Dict objects
//
- (id) findDictKeyword:(NSString *)key
{
	int		i;
	Dict	*dict;

	for (i = 0;i < maxElements;i++)
	{
		dict = [self objectAt:i];
		if ([dict containsObjectForKey:key]) {
			return dict;
		}
	}
	return NULL;
}

@end
