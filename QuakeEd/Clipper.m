
#include "qedefs.h"

Clipper *clipper_i;

@implementation Clipper

- (instancetype)init
{
	if (self = [super init]) {
	clipper_i = self;
	}
	return self;
}

- (BOOL)hide
{
	int		oldnum;
	
	oldnum = num;
	num = 0;
	return (oldnum > 0);
}

- (void)flipNormal
{
	vec3_t	temp;
	
	if (num == 2)
	{
		VectorCopy (pos[0], temp);
		VectorCopy (pos[1], pos[0]);
		VectorCopy (temp, pos[1]);
	}
	else if (num == 3)
	{
		VectorCopy (pos[0], temp);
		VectorCopy (pos[2], pos[0]);
		VectorCopy (temp, pos[2]);
	}	
	else
	{
		qprintf ("no clipplane");
		NSBeep ();
	}
	
}

- (BOOL)getFace: (face_t *)f
{
	vec3_t	v1, v2, norm;
	int		i;
	
	VectorCopy (vec3_origin, plane.normal);
	plane.dist = 0;
	if (num < 2)
		return NO;
	if (num == 2)
	{
		VectorCopy (pos[0], pos[2]);
		pos[2][2] += 16;
	}
	
	for (i=0 ; i<3 ; i++)
		VectorCopy (pos[i], f->planepts[i]);
		
	VectorSubtract (pos[2], pos[0], v1);
	VectorSubtract (pos[1], pos[0], v2);
	
	CrossProduct (v1, v2, norm);
	VectorNormalize (norm);
	
	if ( !norm[0] && !norm[1] && !norm[2] )
		return NO;
	
	[texturepalette_i getTextureDef: &f->texture];

	return YES;
}

/*
================
XYClick
================
*/
- (void)XYClick: (NSPoint)pt
{
	int		i;
	vec3_t	new;
		
	new[0] = [xyview_i snapToGrid: pt.x];
	new[1] = [xyview_i snapToGrid: pt.y];
	new[2] = [map_i currentMinZ];

// see if a point is allready there
	for (i=0 ; i<num ; i++)
	{
		if (new[0] == pos[i][0] && new[1] == pos[i][1])
		{
			if (pos[i][2] == [map_i currentMinZ])
				pos[i][2] = [map_i currentMaxZ];
			else
				pos[i][2] = [map_i currentMinZ];
			[quakeed_i updateAll];
			return;
		}
	}
	
	
	if (num == 3)
		num = 0;
	
	VectorCopy (new, pos[num]);
	num++;

	[quakeed_i updateAll];
}

/*
================
XYDrag
================
*/
- (BOOL)XYDrag: (NSPoint)pt
{
	int		i;
	
	for (i=0 ; i<3 ; i++)
	{
		if ((fabs(pt.x - pos[i][0]) > 10) || (fabs(pt.y - pos[i][1]) > 10) )
			continue;
	// drag this point
	
	}
	
	return NO;
}

- (void)ZClick: (NSPoint)pt
{
	return;
}

//=============================================================================

- (void)carve
{
	[map_i makeSelectedPerform: @selector(carveByClipper)];
	num = 0;
}


- (void)cameraDrawSelf
{
	vec3_t		mid;
	int			i;
	
	linecolor (1,0.5,0);

	for (i=0 ; i<num ; i++)
	{
		VectorCopy (pos[i], mid);
		mid[0] -= 8;
		mid[1] -= 8;
		CameraMoveto (mid);
		mid[0] += 16;
		mid[1] += 16;
		CameraLineto (mid);
		
		VectorCopy (pos[i], mid);
		mid[0] -= 8;
		mid[1] += 8;
		CameraMoveto (mid);
		mid[0] += 16;
		mid[1] -= 16;
		CameraLineto (mid);
	}
}

- (void)XYDrawSelf
{
	int		i;
	char	text[8];
	
	PSsetrgbcolor (1,0.5,0);
	PSselectfont("Helvetica-Medium",10/[xyview_i currentScale]);
	PSrotate(0);

	for (i=0 ; i<num ; i++)
	{
		PSmoveto (pos[i][0]-4, pos[i][1]-4);
		sprintf (text, "%i", i);
		PSshow (text);
		PSstroke ();
		PSarc ( pos[i][0], pos[i][1], 10, 0, 360);
		PSstroke ();
	}
}

- (void)ZDrawSelf
{
	int		i;
	char	text[8];
	
	PSsetrgbcolor (1,0.5,0);
	PSselectfont("Helvetica-Medium",10/[zview_i currentScale]);
	PSrotate(0);

	for (i=0 ; i<num ; i++)
	{
		PSmoveto (-28+i*8 - 4, pos[i][2]-4);
		sprintf (text, "%i", i);
		PSshow (text);
		PSstroke ();
		PSarc ( -28+i*8, pos[i][2], 10, 0, 360);
		PSstroke ();
	}
}

@end
