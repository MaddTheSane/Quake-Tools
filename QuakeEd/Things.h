
#import <AppKit/AppKit.h>

@class Things;
extern	Things *things_i;

#define	ENTITYNAMEKEY	"spawn"

@interface Things: NSObject <NSBrowserDelegate>
{
	IBOutlet id	entity_browser_i;	// browser
	IBOutlet NSTextView	*entity_comment_i;	// scrolling text window
	
	IBOutlet id	prog_path_i;
	
	NSInteger	lastSelected;	// last row selected in browser

	IBOutlet id	keyInput_i;
	IBOutlet id	valueInput_i;
	IBOutlet id	flags_i;
}

- (void)initEntities;

- (void)newCurrentEntity;
- (void)setSelectedKey:(epair_t *)ep;

- (void)clearInputs;
- (char *)spawnName;

// UI targets
- (IBAction)reloadEntityClasses: sender;
- (IBAction)selectEntity: sender;
- (IBAction)doubleClickEntity: sender;

// Action methods
- (IBAction)addPair:sender;
- (IBAction)delPair:sender;
- (IBAction)setAngle:sender;
- (IBAction)setFlags:sender;


@end
