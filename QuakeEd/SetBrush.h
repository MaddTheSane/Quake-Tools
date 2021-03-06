
#import <Cocoa/Cocoa.h>
#import "XYZDrawable.h"

#define		MAX_FACES		16

typedef float	vec5_t[5];

typedef struct
{
	int		numpoints;
	vec5_t	points[8];			// variable sized
} winding_t;

#define MAX_POINTS_ON_WINDING	64

typedef struct
{
	vec3_t		normal;
	float		dist;
} plane_t;

typedef struct
{
// implicit rep
	vec3_t			planepts[3];
	texturedef_t	texture;

// cached rep
	plane_t			plane;
	qtexture_t		*qtexture;
	float			light;		// 0 - 1.0
	winding_t		*w;
} face_t;

#define	ON_EPSILON		0.1
#define	FP_EPSILON		0.01
#define	VECTOR_EPSILON	0.0001

#define	SIDE_FRONT		0
#define	SIDE_BACK		1
#define	SIDE_ON			2


winding_t *ClipWinding (winding_t *in, plane_t *split);
winding_t	*CopyWinding (winding_t *w);
winding_t *NewWinding (int points);


@interface SetBrush : NSObject <NSCopying, XYZDrawable>
{
	BOOL		regioned;		// not active
	BOOL		selected;

	BOOL		invalid;		// not a proper polyhedron

	NSArray		*parent;			// the entity this brush is in
	vec3_t		bmins, bmaxs;
	vec3_t		entitycolor;
	int			numfaces;
	face_t		faces[MAX_FACES];
}

- (instancetype)initWithOwner:(id) own mins:(float *)mins maxs:(float *)maxs texture:(texturedef_t *)tex;
- (instancetype)initFromTokens: own;
- (void)setMins:(float *)mins maxs:(float *)maxs;

@property (assign) id parent;

- (void)setEntityColor: (vec3_t)color;

- (BOOL)calcWindings;

- (void)writeToFILE: (FILE *)f region: (BOOL)reg;

@property BOOL selected;
@property BOOL regioned;

- (void)getMins: (vec3_t)mins maxs: (vec3_t)maxs;

- (BOOL)containsPoint: (vec3_t)pt;

- (void)freeWindings;
- (BOOL)removeIfInvalid;

extern	vec3_t	region_min, region_max;
- (void)newRegion;

- (texturedef_t *)texturedef NS_RETURNS_INNER_POINTER;
- (texturedef_t *)texturedefForFace: (int)f NS_RETURNS_INNER_POINTER;
- (void)setTexturedef: (texturedef_t *)tex;
- (void)setTexturedef: (texturedef_t *)tex forFace:(int)f;

- (void)XYDrawSelf;
- (void)ZDrawSelf;
- (void)CameraDrawSelf;
- (void)XYRenderSelf;
- (void)CameraRenderSelf;

- (void)hitByRay: (vec3_t)p1 : (vec3_t) p2 : (float *)time : (int *)face;

//
// single brush actions
//
extern	int		numcontrolpoints;
extern	float	*controlpoints[MAX_FACES*3];
- (void)getZdragface: (vec3_t)dragpoint;
- (void)getXYdragface: (vec3_t)dragpoint;
- (void)getXYShearPoints: (vec3_t)dragpoint;

- (id)addFace: (face_t *)f;

//
// multiple brush actions
//
- (void)carveByClipper;

extern	vec3_t	sb_translate;
- (void)translate;

extern	id		carve_in, carve_out;
- (void)select;
- (void)deselect;
- (void)remove;
- (void)flushTextures;

extern	vec3_t	sb_mins, sb_maxs;
- (void)addToBBox;

extern	vec3_t	sel_x, sel_y, sel_z;
extern	vec3_t	sel_org;
- (void)transform;

- (void)flipNormals;

- (void)carve;
- (void)setCarveVars;

extern	id	sb_newowner;
- (void)moveToEntity;

- (void)takeCurrentTexture;

extern	vec3_t	select_min, select_max;
- (void)selectPartial;
- (void)selectComplete;
- (void)regionPartial;
- (void)regionComplete;

extern	float	sb_floor_dir, sb_floor_dist;
- (void)feetToFloor;

- (int) getNumBrushFaces;
- (face_t *)getBrushFace: (int)which;

@end

