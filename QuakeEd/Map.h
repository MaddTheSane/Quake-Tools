
#include "QEOldListAPIs.h"

@class Map;
extern Map *map_i;

/// Map is a list of Entity objects
@interface Map : NSObject
{
	NSMutableArray *objects;
	id		currentEntity;
	NSMutableArray	*oldselection;	// temp when loading a new map
	float	minz, maxz;
}

- newMap;

- writeStats;

- (BOOL)readMapFile: (char *)fname;
- (BOOL)writeMapFile: (char *)fname useRegion: (BOOL)reg;

- entityConnect: (vec3_t)p1 : (vec3_t)p2;

- selectRay: (vec3_t)p1 : (vec3_t)p2 : (BOOL)ef;
- grabRay: (vec3_t)p1 : (vec3_t)p2;
- setTextureRay: (vec3_t)p1 : (vec3_t)p2 : (BOOL)allsides;
- getTextureRay: (vec3_t)p1 : (vec3_t)p2;

- currentEntity;
- (void)setCurrentEntity: ent;

- (float)currentMinZ;
- (void)setCurrentMinZ: (float)m;
- (float)currentMaxZ;
- (void)setCurrentMaxZ: (float)m;

- (int)numSelected;
- (id)selectedBrush;			// returns the first selected brush

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

@interface Map (OldListAPIs) <QEOldListAPIs>
@end
