#import <AppKit/AppKit.h>
#import <objc/List.h>
#import "mathlib.h"
#import "List.h"

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

- (id)initFromText: (char *)text;
- (char *)classname NS_RETURNS_INNER_POINTER;
@property (readonly) esize_t esize;
/// only for esize_fixed
- (float *)mins NS_RETURNS_INNER_POINTER;
/// only for esize_fixed
- (float *)maxs NS_RETURNS_INNER_POINTER;
- (float *)drawColor NS_RETURNS_INNER_POINTER;
- (char *)comments NS_RETURNS_INNER_POINTER;
- (char *)flagName: (unsigned)flagnum NS_RETURNS_INNER_POINTER;

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

