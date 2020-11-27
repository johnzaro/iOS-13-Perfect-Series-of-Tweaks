#import "PSTRootListController.h"

static float headH;

@implementation PSTRootHeaderView

- (instancetype)initWithSpecifier: (PSSpecifier*)specifier
{
	self = [super init];

	UIImage* headerImage = [UIImage imageNamed: @"PSTHeader" inBundle: [NSBundle bundleForClass: [self class]] compatibleWithTraitCollection: nil];
	_aspectRatio = headerImage.size.width / headerImage.size.height;
	_headerImageView = [[UIImageView alloc] initWithImage: headerImage];
	[self addSubview: _headerImageView];

	return self;
}

- (void)setFrame: (CGRect)frame
{
	[super setFrame:CGRectMake(frame.origin.x, 0, frame.size.width, frame.size.height)];
	_headerImageView.frame = CGRectMake(frame.origin.x, 0, frame.size.width, frame.size.height + 35);
	headH = _headerImageView.frame.size.height;
}

- (CGFloat)preferredHeightForWidth: (CGFloat)width
{
	return width / _aspectRatio - 26;
}

+ (CGFloat)headerH
{
	return headH;
}

@end
