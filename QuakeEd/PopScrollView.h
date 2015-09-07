#import <AppKit/AppKit.h>

@interface PopScrollView : NSScrollView
{
	__unsafe_unretained NSButton	*button1, *button2;
}

- (id)initWithFrame:(NSRect)frameRect button1:(NSButton*) b1 button2:(NSButton*) b2;
- (void)tile;

@end