#import <AppKit/AppKit.h>
#import "mathlib.h"

typedef enum {esize_model, esize_fixed} esize_t;

#define	MAX_FLAGS	8

@interface EntityClass : NSObject
{
	NSString*name;
	esize_t	esize;
	vec3_t	mins, maxs;
	vec3_t	color;
	char	*comments;
	char	flagnames[MAX_FLAGS][32];
}

- (id)initFromText: (char *)text;
@property (readonly, copy) NSString *classname;
@property (readonly) esize_t esize;
/// only for esize_fixed
- (float *)mins NS_RETURNS_INNER_POINTER;
/// only for esize_fixed
- (float *)maxs NS_RETURNS_INNER_POINTER;
- (float *)drawColor NS_RETURNS_INNER_POINTER;
- (const char *)comments NS_RETURNS_INNER_POINTER;
- (const char *)flagName: (unsigned)flagnum NS_RETURNS_INNER_POINTER;

@end

@class EntityClassList;
extern EntityClassList *entity_classes_i;


@interface EntityClassList : NSObject
{
	id								nullclass;
	NSString						*source_path;
	NSMutableArray<EntityClass*>	*classList;
}

- (EntityClass*)objectAtIndex:(NSInteger)idx;
- (NSUInteger)indexOfObject:(EntityClass*)anObject;

- (instancetype)initForSourceDirectory: (NSString *)path;
- (id)classForName: (NSString *)name;
- (void)scanDirectory;

@end

