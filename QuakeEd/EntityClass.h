#import <AppKit/AppKit.h>
#import "mathlib.h"
#import "List.h"

typedef enum {esize_model, esize_fixed} esize_t;

#define	MAX_FLAGS	8

@interface EntityClass : NSObject
{
	char	*name;
	esize_t	esize;
	vec3_t	mins, maxs;
	float	color[3];
	char	*comments;
	char	flagnames[MAX_FLAGS][32];
}

- (id)initFromText: (char *)text;
- (char *)classname;
@property (readonly) esize_t esize;
- (vec3_t)mins;		// only for esize_fixed
- (vec3_t)maxs;		// only for esize_fixed
- (float *)drawColor;
- (char *)comments;
- (char *)flagName: (unsigned)flagnum;

@end

@class EntityClassList;
extern EntityClassList *entity_classes_i;

@interface EntityClassList : List
{
	id		nullclass;
	char	*source_path;
}

- (instancetype)initForSourceDirectory: (char *)path;
- (id)classForName: (char *)name;
- (void)scanDirectory;

@end

