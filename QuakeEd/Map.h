
// Map is a list of Entity objects

//#import "List.h"
#import "XYZDrawable.h"

@class SetBrush;
@class Map;
@class Entity;
extern Map *map_i;

@interface Map : NSObject <XYZDrawable>
{
	Entity	*currentEntity;
	NSArray	*oldselection;	// temp when loading a new map
	NSArray *mapData;
	float	minz, maxz;
}

- (void)newMap;

- (void)writeStats;

- (void)readMapFile: (char *)fname;
- (void)writeMapFile: (char *)fname useRegion: (BOOL)reg;

- (void)entityConnect: (vec3_t)p1 : (vec3_t)p2;

- (void)selectRay: (vec3_t)p1 : (vec3_t)p2 : (BOOL)ef;
- (SetBrush*)grabRay: (vec3_t)p1 : (vec3_t)p2;
- (void)setTextureRay: (vec3_t)p1 : (vec3_t)p2 : (BOOL)allsides;
- (SetBrush*)getTextureRay: (vec3_t)p1 : (vec3_t)p2;

@property (assign, nonatomic) Entity *currentEntity;

@property (nonatomic) float currentMinZ;
@property (nonatomic) float currentMaxZ;

@property (readonly) NSInteger numSelected;
- (SetBrush*)selectedBrush;			// returns the first selected brush

//
// operations on current selection
//
- (void)makeSelectedPerform: (SEL)sel;
- (void)makeUnselectedPerform: (SEL)sel;
- (void)makeAllPerform: (SEL)sel;
- (void)makeGlobalPerform: (SEL)sel;	// in and out of region

- (IBAction)cloneSelection:(id) sender;

- (IBAction)makeEntity:(id) sender;

- (IBAction)subtractSelection:(id) sender;

- (IBAction)selectCompletelyInside:(id) sender;
- (IBAction)selectPartiallyInside:(id) sender;

- (IBAction)tallBrush:(id) sender;
- (IBAction)shortBrush:(id) sender;

- (IBAction)rotate_x:(id) sender;
- (IBAction)rotate_y:(id) sender;
- (IBAction)rotate_z:(id) sender;

- (IBAction)flip_x:(id) sender;
- (IBAction)flip_y:(id) sender;
- (IBAction)flip_z:(id) sender;

- (IBAction)selectCompleteEntity:(id) sender;

@end
