
#import <AppKit/AppKit.h>

@class Things;
extern Things *things_i;

#define	ENTITYNAMEKEY	"spawn"

@interface Things:NSObject <NSBrowserDelegate>
{
	IBOutlet NSBrowser	*entity_browser_i;	// browser
	IBOutlet NSTextView	*entity_comment_i;	// scrolling text window
	
	IBOutlet NSTextField	*prog_path_i;
	
	int	lastSelected;	// last row selected in browser

	IBOutlet NSTextField	*keyInput_i;
	IBOutlet NSTextField	*valueInput_i;
	IBOutlet NSMatrix		*flags_i;
}

- initEntities;

- newCurrentEntity;
- setSelectedKey:(epair_t *)ep;

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
