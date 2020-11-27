#import "MusicApp.h"
#import "MusicPreferences.h"
#import "Colorizer.h"

extern BOOL getIsNotchediPhone();
extern void roundCorners(UIView* view, double topCornerRadius, double bottomCornerRadius);

static MusicPreferences *preferences;

static BOOL isNotchediPhone = NO;
static UIColor *staticBackgroundColor;

// -------------------------------------- MUSIC APP GENERAL TINT COLOR  ------------------------------------------------

%group musicAppCustomTintColorGroup

	%hook UIColor

	+ (id)systemPinkColor
	{
		return [preferences musicAppCustomTintColor];
	}

	%end

%end

// -------------------------------------- NOW PLAYING VIEW CUSTOM TINT COLOR  ------------------------------------------------

%group customMusicAppNowPlayingViewTintColorGroup

	%hook NowPlayingViewController

	- (void)viewDidLayoutSubviews
	{
		%orig;
		[self colorize];
	}

	%new
	- (void)colorize
	{
		MusicNowPlayingControlsViewController *musicNowPlayingControlsViewController = MSHookIvar<MusicNowPlayingControlsViewController*>(self, "controlsViewController");
		if([preferences enableMusicAppNowPlayingViewBackgroundStaticColor]
		|| [preferences enableMusicAppNowPlayingViewBorderStaticColor])
		{
			UIView *backgroundView = MSHookIvar<UIView*>(self, "backgroundView");
			UIView *contentView = [backgroundView contentView];
			UIView *newView = [contentView viewWithTag: 0xffeedd];
			if(!newView)
			{
				newView = [[UIView alloc] initWithFrame: [contentView bounds]];
				[newView setAutoresizingMask: UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
				[newView setTag: 0xffeedd];
				[newView setOpaque: NO];
				[newView setClipsToBounds: YES];

				if([preferences enableMusicAppNowPlayingViewBorderStaticColor])
				{
					isNotchediPhone = getIsNotchediPhone();
					
					if(isNotchediPhone)
						roundCorners(newView, 10, 40);
					else
					{
						[[newView layer] setCornerRadius: 10];
						[[newView layer] setBorderWidth: [preferences musicAppNowPlayingViewBorderWidth]];
						[[newView layer] setMaskedCorners: kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner];
					}
				}

				[contentView addSubview: newView];
			}
			
			// [contentView setBackgroundColor: [UIColor clearColor]];

			UIView *bottomContainerView = MSHookIvar<UIView*>(musicNowPlayingControlsViewController, "bottomContainerView");
			[bottomContainerView setCustomBackgroundColor: [UIColor clearColor]];
			[bottomContainerView setBackgroundColor: [UIColor clearColor]];

			if([preferences enableMusicAppNowPlayingViewBackgroundStaticColor])
				[newView setBackgroundColor: [preferences customMusicAppNowPlayingViewBackgroundColor]];

			if([preferences enableMusicAppNowPlayingViewBorderStaticColor])
			{
				if(isNotchediPhone)
					[((CAShapeLayer*)[[newView layer] sublayers][0]) setStrokeColor: [preferences customMusicAppNowPlayingViewBorderColor].CGColor];
				else
					[[newView layer] setBorderColor: [preferences customMusicAppNowPlayingViewBorderColor].CGColor];
			}
		}

		[musicNowPlayingControlsViewController colorize];
	}

	%end

	// -------------------------------------- MusicNowPlayingControlsViewController  ------------------------------------------------

	%hook MusicNowPlayingControlsViewController

	%new
	- (void)colorize
	{
		if([preferences enableMusicAppNowPlayingViewBackgroundStaticColor])
			staticBackgroundColor = [preferences customMusicAppNowPlayingViewBackgroundColor];
		else
		{
			if([[self traitCollection] userInterfaceStyle] == UIUserInterfaceStyleDark)
				staticBackgroundColor = [UIColor blackColor];
			else
				staticBackgroundColor = [UIColor whiteColor];
		}

		if([preferences customMusicAppNowPlayingViewButtonsColor])
		{
			UIView *grabberView = MSHookIvar<UIView*>(self, "grabberView");
			[grabberView setCustomBackgroundColor: [preferences customMusicAppNowPlayingViewButtonsColor]];
			[grabberView setBackgroundColor: [preferences customMusicAppNowPlayingViewButtonsColor]];

			[[self subtitleButton] setCustomTitleColor: [preferences customMusicAppNowPlayingViewButtonsColor]];
			[[self subtitleButton] setTitleColor: [preferences customMusicAppNowPlayingViewButtonsColor] forState: UIControlStateNormal];
			
			[[self accessibilityLyricsButton] setSpecialButton: @1];
			[[self accessibilityLyricsButton] setCustomButtonTintColorWithBackgroundColor: staticBackgroundColor];

			[[self routeButton] setCustomTintColor: [preferences customMusicAppNowPlayingViewButtonsColor]];
			[[self routeButton] setTintColor: [preferences customMusicAppNowPlayingViewButtonsColor]];

			[[self routeLabel] setCustomTextColor: [preferences customMusicAppNowPlayingViewButtonsColor]];
			[[self routeLabel] setTextColor: [preferences customMusicAppNowPlayingViewButtonsColor]];

			[[self accessibilityQueueButton] setSpecialButton: @2];
			[[self accessibilityQueueButton] setCustomButtonTintColorWithBackgroundColor: staticBackgroundColor];

			UIView *queueModeBadgeView = MSHookIvar<UIView*>(self, "queueModeBadgeView");
			[queueModeBadgeView setCustomTintColor: staticBackgroundColor];
			[queueModeBadgeView setTintColor: staticBackgroundColor];
			[queueModeBadgeView setCustomBackgroundColor: [preferences customMusicAppNowPlayingViewButtonsColor]];
			[queueModeBadgeView setBackgroundColor: [preferences customMusicAppNowPlayingViewButtonsColor]];

			[[self leftButton] colorize];
			[[self playPauseStopButton] colorize];
			[[self rightButton] colorize];

			[[[self contextButton] superview] setAlpha: 1.0];
			[[self contextButton] colorize];
		}

		if([preferences enableMusicAppNowPlayingViewTimeControlsStaticColor])
			[MSHookIvar<PlayerTimeControl*>(self, "timeControl") colorize];
		if([preferences enableMusicAppNowPlayingViewVolumeControlsStaticColor])
			[MSHookIvar<MPVolumeSlider*>(self, "volumeSlider") colorize];
	}

	%end

	// -------------------------------------- ContextualActionsButton  ------------------------------------------------

	%hook ContextualActionsButton

	%new
	- (void)colorize
	{
		[self setCustomTintColor: [preferences customMusicAppNowPlayingViewButtonsColor]];
		[self setTintColor: [preferences customMusicAppNowPlayingViewButtonsColor]];

		UIImageView *ellipsisImageView = MSHookIvar<UIImageView*>(self, "ellipsisImageView");
		[ellipsisImageView setCustomTintColor: staticBackgroundColor];
		[ellipsisImageView setTintColor: staticBackgroundColor];
	}

	%end

	// -------------------------------------- PlayerTimeControl  ------------------------------------------------

	%hook PlayerTimeControl

	%new
	- (void)colorize
	{
		[self setCustomTintColor: [preferences customMusicAppNowPlayingViewTimeControlsColor]];
		[self setTintColor: [preferences customMusicAppNowPlayingViewTimeControlsColor]];

		MSHookIvar<UIColor*>(self, "trackingTintColor") = [preferences customMusicAppNowPlayingViewTimeControlsColor];

		[MSHookIvar<UILabel*>(self, "remainingTimeLabel") setCustomTextColor: [preferences customMusicAppNowPlayingViewTimeControlsColor]];
		[MSHookIvar<UILabel*>(self, "remainingTimeLabel") setTextColor: [preferences customMusicAppNowPlayingViewTimeControlsColor]];
		[MSHookIvar<UIView*>(self, "remainingTrack") setCustomBackgroundColor: [preferences customMusicAppNowPlayingViewTimeControlsColor]];
		[MSHookIvar<UIView*>(self, "remainingTrack") setBackgroundColor: [preferences customMusicAppNowPlayingViewTimeControlsColor]];
		[MSHookIvar<UIView*>(self, "knobView") setCustomBackgroundColor: [preferences customMusicAppNowPlayingViewTimeControlsColor]];
		[MSHookIvar<UIView*>(self, "knobView") setBackgroundColor: [preferences customMusicAppNowPlayingViewTimeControlsColor]];
	}

	%end

	// -------------------------------------- NowPlayingTransportButton  ------------------------------------------------

	%hook NowPlayingTransportButton

	- (void)setImage: (id)arg1 forState: (unsigned long long)arg2
	{
		%orig([(UIImage*)arg1 imageWithRenderingMode: UIImageRenderingModeAlwaysTemplate], arg2);
	}

	%new
	- (void)colorize
	{
		[[self imageView] setCustomTintColor: [preferences customMusicAppNowPlayingViewButtonsColor]];
		[[self imageView] setTintColor: [preferences customMusicAppNowPlayingViewButtonsColor]];
		[[[self imageView] layer] setCompositingFilter: 0];

		[MSHookIvar<UIView*>(self, "highlightIndicatorView") setBackgroundColor: [preferences customMusicAppNowPlayingViewButtonsColor]];
	}

	%end

	// -------------------------------------- MPVolumeSlider  ------------------------------------------------

	%hook MPVolumeSlider

	%new
	- (void)colorize
	{
		[self setCustomTintColor: [preferences customMusicAppNowPlayingViewVolumeControlsColor]];
		[self setTintColor: [preferences customMusicAppNowPlayingViewVolumeControlsColor]];

		[[self _minValueView] setTintColor: [preferences customMusicAppNowPlayingViewVolumeControlsColor]];
		[[self _maxValueView] setTintColor: [preferences customMusicAppNowPlayingViewVolumeControlsColor]];

		[self setCustomMinimumTrackTintColor: [preferences customMusicAppNowPlayingViewVolumeControlsColor]];
		[self setMinimumTrackTintColor: [preferences customMusicAppNowPlayingViewVolumeControlsColor]];
		[self setCustomMaximumTrackTintColor: [preferences customMusicAppNowPlayingViewVolumeControlsColor]];
		[self setMaximumTrackTintColor: [preferences customMusicAppNowPlayingViewVolumeControlsColor]];

		[[self thumbView] setCustomTintColor: [preferences customMusicAppNowPlayingViewVolumeControlsColor]];
		[[self thumbView] setTintColor: [preferences customMusicAppNowPlayingViewVolumeControlsColor]];
		[[[self thumbView] layer] setShadowColor: [preferences customMusicAppNowPlayingViewVolumeControlsColor].CGColor];
		if([[self thumbImageForState: UIControlStateNormal] renderingMode] != UIImageRenderingModeAlwaysTemplate)
			[self setThumbImage: [[self thumbImageForState: UIControlStateNormal] imageWithRenderingMode: UIImageRenderingModeAlwaysTemplate] forState: UIControlStateNormal];
	}

	%end

	%hook MiniPlayerViewController

	- (void)viewDidLayoutSubviews
	{
		%orig;
		[self colorize];
	}

	- (void)controller: (id)arg1 defersResponseReplacement: (id)arg2
	{
		%orig;
		dispatch_async(dispatch_get_main_queue(),
		^{
			[self colorize];
		});
	}

	%new
	- (void)colorize
	{
		if([preferences customMusicAppNowPlayingViewButtonsColor])
		{
			[[self playPauseButton] colorize];
			[[self skipButton] colorize];
		}
	}

	%end

	%hook NowPlayingQueueViewController

	- (void)viewDidLayoutSubviews
	{
		%orig;
		[self colorize];
	}

	%new
	- (void)colorize
	{
		if([preferences customMusicAppNowPlayingViewButtonsColor])
		{
			[MSHookIvar<NowPlayingQueueHeaderView*>(self, "upNextHeader") colorize];
			[MSHookIvar<NowPlayingHistoryHeaderView*>(self, "historyHeader") colorize];
		}
	}

	%end

	%hook NowPlayingHistoryHeaderView

	%new
	- (void)colorize
	{
		for (UIView *subview in [self subviews])
		{
			if([subview isKindOfClass: %c(UIButton)])
				[(UIButton*)subview setTintColor: [preferences customMusicAppNowPlayingViewButtonsColor]];
		}
	}

	%end

	%hook NowPlayingQueueHeaderView

	- (void)viewDidLayoutSubviews
	{
		%orig;
		[self colorize];
	}

	%new
	- (void)colorize
	{
		[MSHookIvar<MPButton*>(self, "subtitleButton") setTintColor: [preferences customMusicAppNowPlayingViewButtonsColor]];

		MPButton *shuffleButton = MSHookIvar<MPButton*>(self, "shuffleButton");
		[shuffleButton setSpecialButton: @3];
		[shuffleButton setCustomButtonTintColorWithBackgroundColor: staticBackgroundColor];

		MPButton *repeatButton = MSHookIvar<MPButton*>(self, "repeatButton");
		[repeatButton setSpecialButton: @3];
		[repeatButton setCustomButtonTintColorWithBackgroundColor: staticBackgroundColor];
	}

	%end

%end

void initMusicApp_StaticColors()
{
	preferences = [MusicPreferences sharedInstance];

	if([preferences enableMusicAppCustomTintColor])
		%init(musicAppCustomTintColorGroup);

	if([preferences musicAppNowPlayingViewColorsStyle] == 2)
		%init(customMusicAppNowPlayingViewTintColorGroup,
			NowPlayingViewController = NSClassFromString(@"MusicApplication.NowPlayingViewController"),
			PlayerTimeControl = NSClassFromString(@"MusicApplication.PlayerTimeControl"),
			NowPlayingTransportButton = NSClassFromString(@"MusicApplication.NowPlayingTransportButton"),
			MiniPlayerViewController = NSClassFromString(@"MusicApplication.MiniPlayerViewController"),
			NowPlayingQueueViewController = NSClassFromString(@"MusicApplication.NowPlayingQueueViewController"),
			NowPlayingQueueHeaderView = NSClassFromString(@"MusicApplication.NowPlayingQueueHeaderView"),
			NowPlayingHistoryHeaderView = NSClassFromString(@"MusicApplication.NowPlayingHistoryHeaderView"),
			QueueGradientView = NSClassFromString(@"MusicApplication.QueueGradientView"),
			ContextualActionsButton = NSClassFromString(@"MusicApplication.ContextualActionsButton"));
}