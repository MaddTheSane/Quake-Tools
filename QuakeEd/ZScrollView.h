#import <AppKit/AppKit.h>

@interface ZScrollView : NSScrollView
{
	NSButton	*button1;
}

- (instancetype)initWithFrame:(NSRect)frameRect button1: b1;
- (void)tile;

@end