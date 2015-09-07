
// Map is a list of Entity objects

#import "List.h"

@class SetBrush;

extern	id	map_i;

@interface Map : List
{
	id		currentEntity;
	List	*oldselection;	// temp when loading a new map
	float	minz, maxz;
}

- newMap;

- writeStats;

- readMapFile: (char *)fname;
- writeMapFile: (char *)fname useRegion: (BOOL)reg;

- entityConnect: (vec3_t)p1 : (vec3_t)p2;

- selectRay: (vec3_t)p1 : (vec3_t)p2 : (BOOL)ef;
- grabRay: (vec3_t)p1 : (vec3_t)p2;
- setTextureRay: (vec3_t)p1 : (vec3_t)p2 : (BOOL)allsides;
- getTextureRay: (vec3_t)p1 : (vec3_t)p2;

- currentEntity;
- setCurrentEntity: ent;

@property (nonatomic) float currentMinZ;
@property (nonatomic) float currentMaxZ;

- (float)currentMinZ;
- (void)setCurrentMinZ: (float)m;
- (float)currentMaxZ;
- (void)setCurrentMaxZ: (float)m;

- (int)numSelected;
- (SetBrush*)selectedBrush;			// returns the first selected brush

//
// operations on current selection
//
- makeSelectedPerform: (SEL)sel;
- makeUnselectedPerform: (SEL)sel;
- makeAllPerform: (SEL)sel;
- makeGlobalPerform: (SEL)sel;	// in and out of region

- (IBAction)cloneSelection: sender;

- (IBAction)makeEntity: sender;

- (IBAction)subtractSelection: sender;

- (IBAction)selectCompletelyInside: sender;
- (IBAction)selectPartiallyInside: sender;

- (IBAction)tallBrush: sender;
- (IBAction)shortBrush: sender;

- (IBAction)rotate_x: sender;
- (IBAction)rotate_y: sender;
- (IBAction)rotate_z: sender;

- (IBAction)flip_x: sender;
- (IBAction)flip_y: sender;
- (IBAction)flip_z: sender;

- (IBAction)selectCompleteEntity: sender;

@end
