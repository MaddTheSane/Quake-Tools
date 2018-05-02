#import <AppKit/AppKit.h>
#import "mathlib.h"
#import "QEOldListAPIs.h"

typedef enum {esize_model, esize_fixed} esize_t;

#define	MAX_FLAGS	8

@interface EntityClass : NSObject
{
	char	*name;
	esize_t	esize;
	vec3_t	mins, maxs;
	vec3_t	color;
	char	*comments;
	char	flagnames[MAX_FLAGS][32];
}

- initFromText: (char *)text;
- (char *)classname;
- (esize_t)esize;
- (float *)mins;		// only for esize_fixed
- (float *)maxs;		// only for esize_fixed
- (float *)drawColor;
- (char *)comments;
- (char *)flagName: (unsigned)flagnum;

@end

@class EntityClassList;
extern EntityClassList *entity_classes_i;

@interface EntityClassList : NSObject
{
	id		nullclass;
	char	*source_path;
}

- initForSourceDirectory: (char *)path;
- (id)classForName: (char *)name;
- (void)scanDirectory;

@end

@interface EntityClassList (OldListAPIs) <QEOldListAPIs>

@end
