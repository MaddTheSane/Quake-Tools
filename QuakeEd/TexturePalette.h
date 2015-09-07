
#import <AppKit/AppKit.h>

typedef union
{
	byte		chan[4];
	unsigned	p;
} pixel32_t;


typedef struct
{
	char	texture[16];
	float	rotate;
	float	shift[2];
	float	scale[2];
} texturedef_t;


typedef struct
{
	char		name[16];
	
	int			width;
	int			height;
	NSBitmapImageRep	*rep;
	void		*data;
	pixel32_t	flatcolor;
} qtexture_t;

#define	MAX_TEXTURES	1024

extern	int					tex_count;
extern	qtexture_t 		qtextures[MAX_TEXTURES];

void	TEX_InitFromWad (char *path);
qtexture_t *TEX_ForName (char *name);


typedef struct
{
	NSImage		*image;		// NXImage
	NSRect	r;
	char	*name;
	int		index;
	int		display;	// flag (on/off)
} texpal_t;

#define	TEX_INDENT	10
#define	TEX_SPACING	16

extern	id texturepalette_i;

@interface TexturePalette: NSObject
{
	char	currentwad[1024];
	id	textureList_i;
	IBOutlet id	textureView_i;
	IBOutlet id	searchField_i;
	IBOutlet id	sizeField_i;
	
	id	field_Xshift_i;
	id	field_Yshift_i;
	id	field_Xscale_i;
	id	field_Yscale_i;
	id	field_Rotate_i;
	
	int	viewWidth;
	int	viewHeight;
	int	selectedTexture;
}

- (char*)currentWad;
- (id)initPaletteFromWadfile:(char *)wf;
- computeTextureViewSize;
- alphabetize;
- getList;
- (int)getSelectedTexture;
- setSelectedTexture:(int)which;
- (int)getSelectedTexIndex;

// Called externally
- (char *)getSelTextureName;
- setTextureByName:(char *)name;

// New methods to replace the 2 above ones
- setTextureDef:(texturedef_t *)td;
- getTextureDef:(texturedef_t *)td;

// Action methods
- (IBAction)searchForTexture:sender;

- (IBAction)clearTexinfo: sender;

- (IBAction)incXShift:sender;
- (IBAction)decXShift:sender;

- (IBAction)incYShift:sender;
- (IBAction)decYShift:sender;

- (IBAction)incRotate: sender;
- (IBAction)decRotate: sender;

- (IBAction)incXScale:sender;
- (IBAction)decXScale:sender;

- (IBAction)incYScale:sender;
- (IBAction)decYScale:sender;

- (IBAction)texturedefChanged: sender;
- (IBAction)onlyShowMapTextures:sender;
- (int) searchForTextureInPalette:(char *)texture;
- setDisplayFlag:(int)index to:(int)value;

@end
