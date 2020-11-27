#import "MusicSpringboard.h"

%hook UILabel

- (void)setTextColor: (UIColor *)arg1
{
	UIColor *color = [self customTextColor];
	if(color) %orig(color);
	else %orig;
}

%new
- (UIColor*)customTextColor
{
	return (UIColor*)objc_getAssociatedObject(self, @selector(customTextColor));
}

%new
- (void)setCustomTextColor: (UIColor*)arg
{
	objc_setAssociatedObject(self, @selector(customTextColor), arg, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%end

%hook UIView

- (void)setBackgroundColor: (UIColor*)arg
{
	UIColor *color = [self customBackgroundColor];
	if(color) %orig(color);
	else %orig;
}

%new
- (UIColor*)customBackgroundColor
{
	return (UIColor*)objc_getAssociatedObject(self, @selector(customBackgroundColor));
}

%new
- (void)setCustomBackgroundColor: (UIColor*)arg
{
	objc_setAssociatedObject(self, @selector(customBackgroundColor), arg, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%end

%hook CAShapeLayer

- (void)setStrokeColor: (CGColorRef)arg1
{
	UIColor *color = [self customStrokeColor];
	if(color) %orig(color.CGColor);
	else %orig;
}

%new
- (UIColor*)customStrokeColor
{
	return (UIColor*)objc_getAssociatedObject(self, @selector(customStrokeColor));
}

%new
- (void)setCustomStrokeColor: (UIColor*)arg
{
	objc_setAssociatedObject(self, @selector(customStrokeColor), arg, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%end

%hook UIImageView

- (void)setTintColor: (UIColor*)arg
{
	UIColor *color = [self customTintColor];
	if(color) %orig(color);
	else %orig;
}

%new
- (UIColor*)customTintColor
{
	return (UIColor*)objc_getAssociatedObject(self, @selector(customTintColor));
}

%new
- (void)setCustomTintColor: (UIColor*)arg
{
	objc_setAssociatedObject(self, @selector(customTintColor), arg, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%end

%hook MRPlatterViewController

	%new
	- (BOOL)isViewControllerOfLockScreenMusicWidget
	{
		return [[self parentViewController] isKindOfClass: %c(CSMediaControlsViewController)];
	}

	%new
	- (BOOL)isViewControllerOfControlCenterMusicWidget
	{
		return [[self parentViewController] isKindOfClass: %c(MediaControlsEndpointsViewController)];
	}

	%end

void initMusicWidgetHelper()
{
	%init;
}