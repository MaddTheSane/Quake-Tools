

@interface TextureView: NSView
{
	id	parent_i;
	int	deselectIndex;
}
@property (nonatomic, assign) id parent;

- (void)deselect;

@end
