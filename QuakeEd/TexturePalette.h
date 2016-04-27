
#import <AppKit/AppKit.h>

typedef union
{
	byte			chan[4];
	unsigned int	p;
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

@class TexturePalette;
extern TexturePalette *texturepalette_i;

@interface TexturePalette: NSObject
{
	char	currentwad[1024];
	id	textureList_i;
	IBOutlet id	textureView_i;
	IBOutlet NSTextField *searchField_i;
	IBOutlet NSTextField *sizeField_i;
	
	IBOutlet NSTextField *field_Xshift_i;
	IBOutlet NSTextField *field_Yshift_i;
	IBOutlet NSTextField *field_Xscale_i;
	IBOutlet NSTextField *field_Yscale_i;
	IBOutlet NSTextField *field_Rotate_i;
	
	int	viewWidth;
	int	viewHeight;
	int	selectedTexture;
}

- (char*)currentWad;
- (void)setUpPaletteFromWadfile:(char *)wf;
- (void)computeTextureViewSize;
- (void)alphabetize;
- (id)getList;
@property (getter=getSelectedTexture) int selectedTexture;
- (int)getSelectedTexture;
- (void)setSelectedTexture:(int)which;
- (int)getSelectedTexIndex;

// Called externally
- (NSString *)getSelTextureName;
- (void)setTextureByName:(NSString *)name;

// New methods to replace the 2 above ones
- setTextureDef:(texturedef_t *)td;
- getTextureDef:(texturedef_t *)td;

// Action methods
- (IBAction)searchForTexture:(id)sender;

- (IBAction)clearTexinfo:(id) sender;

- (IBAction)incXShift:(id)sender;
- (IBAction)decXShift:(id)sender;

- (IBAction)incYShift:(id)sender;
- (IBAction)decYShift:(id)sender;

- (IBAction)incRotate:(id) sender;
- (IBAction)decRotate:(id) sender;

- (IBAction)incXScale:(id)sender;
- (IBAction)decXScale:(id)sender;

- (IBAction)incYScale:(id)sender;
- (IBAction)decYScale:(id)sender;

- (IBAction)texturedefChanged:(id) sender;
- (IBAction)onlyShowMapTextures:(id)sender;
- (int) searchForTextureInPalette:(char *)texture;
- (void)setDisplayFlag:(int)index to:(int)value;

@end
