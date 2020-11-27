#import "MusicSpringboard.h"
#import "MusicPreferences.h"

static NSInteger style;
static BOOL lockScreenMusicWidgetHideAlbumArtwork;
static BOOL lockScreenMusicWidgetHideRoutingButton;
static BOOL isIpad;

static CGFloat mediaWidgetWidth = 0;

// ------------------ CSAdjunctItemView ------------------

%hook CSAdjunctItemView

- (void)layoutSubviews
{
	%orig;

	if(mediaWidgetWidth == 0)
		mediaWidgetWidth = [self frame].size.width;
}

%end

// ------------------ CSMediaControlsViewController ------------------

%hook CSMediaControlsViewController

- (CGRect)_suggestedFrameForMediaControls
{
	CGRect frame = %orig;
	if(style == 0)
		frame.size.height = 107;
	else if(style == 1)
		frame.size.height = 130;
	else if(style == 2)
		frame.size.height = 123;
	else
		frame.size.height = 160;
	return frame;
}

%end

%hook MRPlatterViewController

- (void)viewWillLayoutSubviews
{
	%orig;

	if([[self parentViewController] isKindOfClass: %c(CSMediaControlsViewController)])
	{
		if(!lockScreenMusicWidgetHideRoutingButton)
			[[[self nowPlayingHeaderView] routingButton] setTransform: CGAffineTransformScale(CGAffineTransformIdentity, 0.8, 0.8)];

		if(style == 0 || style == 2)
			[[[[self parentContainerView] containerView] timeControl] removeFromSuperview];
		if(style < 2)
			[[self volumeContainerView] removeFromSuperview];
	}
}

%end

// ------------------ MediaControlsHeaderView ------------------

%hook MediaControlsHeaderView

- (void)setFrame: (CGRect)frame
{
	if([[[self _viewControllerForAncestor] parentViewController] isKindOfClass: %c(CSMediaControlsViewController)])
		frame.size.width = mediaWidgetWidth * (isIpad ? 0.6835 : 0.5905);
	%orig;
}

- (CGRect)frame
{
	CGRect frame = %orig;
	if([[[self _viewControllerForAncestor] parentViewController] isKindOfClass: %c(CSMediaControlsViewController)])
		frame.size.width = mediaWidgetWidth * (isIpad ? 0.6835 : 0.5905);
	return frame;
}

- (CGSize)layoutTextInAvailableBounds: (CGRect)frame setFrames: (BOOL)arg2
{
	if([[[self _viewControllerForAncestor] parentViewController] isKindOfClass: %c(CSMediaControlsViewController)])
	{
		if(lockScreenMusicWidgetHideAlbumArtwork)
		{
			frame.origin.x = 18;
			frame.size.width = mediaWidgetWidth * (isIpad ? 0.6655 : 0.5571);
		}
		else
			frame.size.width = mediaWidgetWidth * (isIpad ? 0.5396 : 0.3760);
	}

	return %orig;
}

- (UIView*)hitTest: (CGPoint)point withEvent: (UIEvent*)event
{
    CGPoint translatedPoint = [[self routingButton] convertPoint: point fromView: self];

    if(CGRectContainsPoint([[self routingButton] bounds], translatedPoint))
        return [[self routingButton] hitTest: translatedPoint withEvent: event];
    
    return %orig;

}

- (BOOL)pointInside: (CGPoint)point withEvent: (UIEvent*)event
{
	if(CGRectContainsPoint([[self routingButton] frame], point))
		return YES;
	
	return %orig;
}

%end

%hook MediaControlsRoutingButtonView

- (void)setFrame: (CGRect)frame
{
	if(!lockScreenMusicWidgetHideRoutingButton && [[self _rootView] isKindOfClass: %c(SBCoverSheetWindow)])
	{
		if(isIpad)
		{
			if(NSClassFromString(@"NextUpMediaHeaderView"))
				frame.origin.x = mediaWidgetWidth * 0.9028;
			else
				frame.origin.x = mediaWidgetWidth * 0.9208;
		}
		else
		{
			if(NSClassFromString(@"NextUpMediaHeaderView"))
				frame.origin.x = mediaWidgetWidth * 0.8440;
			else
				frame.origin.x = mediaWidgetWidth * 0.8774;
		}
		frame.origin.y = -20;
	}
	%orig;
}

- (CGRect)frame
{
	CGRect frame = %orig;
	if(!lockScreenMusicWidgetHideRoutingButton && [[self _rootView] isKindOfClass: %c(SBCoverSheetWindow)])
	{
		if(isIpad)
		{
			if(NSClassFromString(@"NextUpMediaHeaderView"))
				frame.origin.x = mediaWidgetWidth * 0.9028;
			else
				frame.origin.x = mediaWidgetWidth * 0.9208;
		}
		else
		{
			if(NSClassFromString(@"NextUpMediaHeaderView"))
				frame.origin.x = mediaWidgetWidth * 0.8440;
			else
				frame.origin.x = mediaWidgetWidth * 0.8774;
		}
		frame.origin.y = -20;
	}
	return frame;
}

%end

// ------------------ MediaControlsParentContainerView ------------------

%hook MediaControlsParentContainerView

- (void)setFrame: (CGRect)frame
{
	if([[self _rootView] isKindOfClass: %c(SBCoverSheetWindow)])
		frame = [[self superview] frame];
	%orig;
}

- (CGRect)frame
{
	CGRect frame = %orig;
	if([[self _rootView] isKindOfClass: %c(SBCoverSheetWindow)])
		frame = [[self superview] frame];
	return frame;
}

%end

// ------------------ MediaControlsContainerView ------------------

%hook MediaControlsContainerView

- (void)setFrame: (CGRect)frame
{
	if([[self _rootView] isKindOfClass: %c(SBCoverSheetWindow)])
		frame = [[self superview] frame];
	%orig;
}

- (CGRect)frame
{
	CGRect frame = %orig;
	if([[self _rootView] isKindOfClass: %c(SBCoverSheetWindow)])
		frame = [[self superview] frame];
	return frame;
}

- (void)layoutSubviews
{
	%orig;

	if([[self _rootView] isKindOfClass: %c(SBCoverSheetWindow)])
	{
		MediaControlsTimeControl *timeControl = [self timeControl];
		if(style == 1 || style == 3)
		{
			CGRect timeFrame = [timeControl frame];
			timeFrame.origin.y = 70;
			[timeControl setFrame: timeFrame];
		}	
		else
			[timeControl removeFromSuperview];
	}
}

%end

// ------------------ MediaControlsTransportStackView ------------------

%hook MediaControlsTransportStackView

- (void)setFrame: (CGRect)frame
{
	if([[self _rootView] isKindOfClass: %c(SBCoverSheetWindow)])
	{
		frame.origin.x = mediaWidgetWidth * (isIpad ? 0.6978 : 0.5571);
		frame.origin.y = 37;
		frame.size.width = 150;
		frame.size.height = 35;
	}
	%orig;
}

- (CGRect)frame
{
	CGRect frame = %orig;
	if([[self _rootView] isKindOfClass: %c(SBCoverSheetWindow)])
	{
		frame.origin.x = mediaWidgetWidth * (isIpad ? 0.6978 : 0.5571);
		frame.origin.y = 37;
		frame.size.width = 150;
		frame.size.height = 35;
	}
	return frame;
}

- (void)layoutSubviews
{
	%orig;
	
	if([[self _rootView] isKindOfClass: %c(SBCoverSheetWindow)])
		[[self tvRemoteButton] setHidden: YES];
}

%end

// ------------------ MediaControlsVolumeContainerView ------------------

%hook MediaControlsVolumeContainerView

- (void)setFrame: (CGRect)frame
{
	if([[self _rootView] isKindOfClass: %c(SBCoverSheetWindow)])
	{
		if(style == 2)
			frame.origin.y = 70;
		else if(style == 3)
			frame.origin.y = 105;
	}
	%orig;
}

- (CGRect)frame
{
	CGRect frame = %orig;
	if([[self _rootView] isKindOfClass: %c(SBCoverSheetWindow)])
	{
		if(style == 2)
			frame.origin.y = 70;
		else if(style == 3)
			frame.origin.y = 105;
	}
	return frame;
}

%end

void initCompactMediaPlayer()
{
	style = [[MusicPreferences sharedInstance] lockScreenMusicWidgetCompactStyle];
	lockScreenMusicWidgetHideAlbumArtwork = [[MusicPreferences sharedInstance] lockScreenMusicWidgetHideAlbumArtwork];
	lockScreenMusicWidgetHideRoutingButton = [[MusicPreferences sharedInstance] lockScreenMusicWidgetHideRoutingButton];
	isIpad = [[MusicPreferences sharedInstance] isIpad];

	%init;
}
