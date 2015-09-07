

@interface TextureView: NSView
{
	id	parent_i;
	int	deselectIndex;
}

- (void)setParent:(id)from;
- (void)deselect;

@end
