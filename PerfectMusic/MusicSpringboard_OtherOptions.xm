#import "MusicPreferences.h"
#import "MusicSpringboard.h"

static MusicPreferences *preferences;

NSInteger cornerMask = 0;

static void produceLightVibration()
{
	UIImpactFeedbackGenerator *gen = [[UIImpactFeedbackGenerator alloc] initWithStyle: UIImpactFeedbackStyleLight];
	[gen prepare];
	[gen impactOccurred];
}

%group lockscreenMusicWidgetCornerRadiusGroup

	%hook MRPlatterViewController

	- (void)viewDidLayoutSubviews
	{
		%orig;

		if([self isViewControllerOfLockScreenMusicWidget])
		{
			[[[[self nowPlayingHeaderView] artworkView] layer] setCornerRadius: [preferences lockScreenAlbumArtworkCornerRadius]];

			UIView *backgroundView = [[[[[self view] superview] superview] superview] subviews][0];

			[[backgroundView layer] setCornerRadius: [preferences lockScreenMusicWidgetCornerRadius]];
			[[backgroundView layer] setMaskedCorners: cornerMask];
		}
	}

	%end

%end

%group lockscreenMusicWidgetTransparentBackgroundGroup

	%hook CSMediaControlsView

	- (void)layoutSubviews
	{
		%orig;

		[[[[self superview] superview] subviews][0] setAlpha: 0];
	}

	%end

%end

%group vibrateMusicWidgetGroup

	%hook MediaControlsRoutingButtonView

	- (void)touchesBegan: (id)arg1 withEvent: (id)arg2
	{
		produceLightVibration();
		%orig;
	}

	%end

	%hook MediaControlsTransportButton

	- (void)touchesBegan: (id)arg1 withEvent: (id)arg2
	{
		produceLightVibration();
		%orig;
	}

	%end

	%hook MediaControlsTimeControl

	- (void)touchesBegan: (id)arg1 withEvent: (id)arg2
	{
		produceLightVibration();
		%orig;
	}

	%end

	%hook MediaControlsVolumeSlider

	- (void)touchesBegan: (id)arg1 withEvent: (id)arg2
	{
		produceLightVibration();
		%orig;
	}

	%end

%end

%group lockScreenMusicWidgetHideAlbumArtworkGroup

	%hook MediaControlsHeaderView

	- (void)layoutSubviews
	{
		%orig;

		if([preferences lockScreenMusicWidgetHideAlbumArtwork] && [[[self _viewControllerForAncestor] parentViewController] isKindOfClass: %c(CSMediaControlsViewController)])
		{
			[[self artworkBackground] removeFromSuperview];
			[[self placeholderArtworkView] removeFromSuperview];
			[[self artworkView] removeFromSuperview];
			[[self shadow] removeFromSuperview];
		}
	}

	%end

%end

%group lockScreenMusicWidgetHideRoutingButtonGroup

	%hook MRPlatterViewController

	- (void)viewDidLayoutSubviews
	{
		%orig;
		
		if([self isViewControllerOfLockScreenMusicWidget])
			[[[self nowPlayingHeaderView] routingButton] removeFromSuperview];
	}

	%end

%end

void initMusicWidget_OtherOptions()
{
	preferences = [MusicPreferences sharedInstance];

	if(![preferences disableTopLeftCornerRadius])
		cornerMask += kCALayerMinXMinYCorner;
	if(![preferences disableTopRightCornerRadius])
		cornerMask += kCALayerMaxXMinYCorner;
	if(![preferences disableBottomLeftCornerRadius])
		cornerMask += kCALayerMinXMaxYCorner;
	if(![preferences disableBottomRightCornerRadius])
		cornerMask += kCALayerMaxXMaxYCorner;

	%init(lockscreenMusicWidgetCornerRadiusGroup);
	
	if([preferences lockscreenMusicWidgetTransparentBackground])
		%init(lockscreenMusicWidgetTransparentBackgroundGroup);

	if([preferences vibrateMusicWidget] && ![preferences isIpad])
		%init(vibrateMusicWidgetGroup);
	
	if([preferences lockScreenMusicWidgetHideAlbumArtwork])
		%init(lockScreenMusicWidgetHideAlbumArtworkGroup);

	if([preferences lockScreenMusicWidgetHideRoutingButton])
		%init(lockScreenMusicWidgetHideRoutingButtonGroup);
}