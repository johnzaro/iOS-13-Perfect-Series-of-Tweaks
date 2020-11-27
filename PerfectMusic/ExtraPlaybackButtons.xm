#import "MusicSpringboard.h"
#import "MusicPreferences.h"

static NSMutableArray *shuffleImages;
static NSMutableArray *repeatImages;

static MusicPreferences *preferences;

%hook MediaControlsTransportStackView

- (id)initWithFrame: (CGRect)arg1
{
	self = %orig;

	if(!shuffleImages)
	{
		NSBundle *bundle = [[NSBundle alloc] initWithPath: @"/Library/PreferenceBundles/PerfectMusicPrefs.bundle"];
		shuffleImages = [[NSMutableArray alloc] init];
		repeatImages = [[NSMutableArray alloc] init];
		[shuffleImages addObject: [[UIImage imageNamed: @"Shuffle-Off" inBundle: bundle compatibleWithTraitCollection: nil] imageWithRenderingMode: UIImageRenderingModeAlwaysTemplate]];
		[shuffleImages addObject: [[UIImage imageNamed: @"Shuffle-On" inBundle: bundle compatibleWithTraitCollection: nil] imageWithRenderingMode: UIImageRenderingModeAlwaysTemplate]];
		[repeatImages addObject: [[UIImage imageNamed: @"Repeat-Off" inBundle: bundle compatibleWithTraitCollection: nil] imageWithRenderingMode: UIImageRenderingModeAlwaysTemplate]];
		[repeatImages addObject: [[UIImage imageNamed: @"Repeat-One" inBundle: bundle compatibleWithTraitCollection: nil] imageWithRenderingMode: UIImageRenderingModeAlwaysTemplate]];
		[repeatImages addObject: [[UIImage imageNamed: @"Repeat-All" inBundle: bundle compatibleWithTraitCollection: nil] imageWithRenderingMode: UIImageRenderingModeAlwaysTemplate]];
	}

	MediaControlsTransportButton *shuffleButton = [self _createTransportButton];
	[shuffleButton addTarget: self action: @selector(shuffleButtonPressed) forControlEvents: UIControlEventTouchUpInside];
	[shuffleButton setImage: shuffleImages[0] forState: UIControlStateNormal];
	[shuffleButton sizeToFit];
	[shuffleButton setHidden: YES];
	[shuffleButton setUserInteractionEnabled: YES];

	MediaControlsTransportButton *repeatButton = [self _createTransportButton];
	[repeatButton addTarget: self action: @selector(repeatButtonPressed) forControlEvents: UIControlEventTouchUpInside];
	[repeatButton setImage: repeatImages[0] forState: UIControlStateNormal];
	[repeatButton sizeToFit];
	[repeatButton setHidden: YES];
	[repeatButton setUserInteractionEnabled: YES];

	[self setShuffleButton: shuffleButton];
	[self setRepeatButton: repeatButton];

	return self;
}

- (void)setResponse: (MPCPlayerResponse*)arg
{
	MPCPlayerResponse *oldResponse = [self response];
	%orig;
	if([[self hasExtraButtons] isEqual: @YES] && oldResponse != arg)
		[self updateButtonIcons: YES];
}

- (void)_updateVisualStylingForButtons
{
	%orig;
	if([[self hasExtraButtons] isEqual: @YES])
	{
		[self _updateButtonVisualStyling: [self shuffleButton]];
		[self _updateButtonVisualStyling: [self repeatButton]];
	}
}

- (void)_updateButtonLayout
{
	%orig;

	if(![[self hasExtraButtons] isEqual: @YES] && ![[self hasExtraButtons] isEqual: @NO])
	{
		UIViewController *controller = [[self  _viewControllerForAncestor] parentViewController];
		if([controller isKindOfClass: %c(CSMediaControlsViewController)] || [controller isKindOfClass: %c(MediaControlsEndpointsViewController)])
		{
			if([preferences addExtraButtonsToLockScreen] && [preferences lockScreenMusicWidgetStyle] == 0 && [controller isKindOfClass: %c(CSMediaControlsViewController)]
			|| [preferences addExtraButtonsToControlCenter] && [controller isKindOfClass: %c(MediaControlsEndpointsViewController)])
				[self setHasExtraButtons: @YES];
			else
				[self setHasExtraButtons: @NO];
		}
	}

	if([[self hasExtraButtons] isEqual: @YES])
		[self updateButtonIcons: NO];
}

- (void)layoutSubviews
{
	%orig;

	if([[self hasExtraButtons] isEqual: @YES])
	{
		MediaControlsTransportButton *shuffleButton = [self shuffleButton];
		MediaControlsTransportButton *repeatButton = [self repeatButton];
		if([[self extraButtonsShown] isEqual: @YES])
		{
			MediaControlsTransportButton *leftButton = [self leftButton];
			MediaControlsTransportButton *middleButton = [self middleButton];
			MediaControlsTransportButton *rightButton = [self rightButton];

			CGRect originalFrame = [leftButton frame];
			float y = originalFrame.origin.y;
			float width = originalFrame.size.width;
			float height = originalFrame.size.height;
			float fullWidth = [self frame].size.width;
			float space = (fullWidth - 5 * width) / 6;

			[shuffleButton setFrame: CGRectMake(space, y, width, height)];
			[leftButton setFrame: CGRectMake(space * 2 + width, y, width, height)];
			[middleButton setFrame: CGRectMake(space * 3 + width * 2, y, width, height)];
			[rightButton setFrame: CGRectMake(space * 4 + width * 3, y, width, height)];
			[repeatButton setFrame: CGRectMake(space * 5 + width * 4, y, width, height)];

			[shuffleButton setHidden: NO];
			[repeatButton setHidden: NO];
		}
		else
		{
			[shuffleButton setHidden: YES];
			[repeatButton setHidden: YES];
		}
	}
}

%new
- (void)shuffleButtonPressed
{
	if(![[self shuffleButton] isHolding])
	{
		id advance = [[[[self response] tracklist] shuffleCommand] advance];
		if(advance)
			[%c(MPCPlayerChangeRequest) performRequest: advance completion: nil];
	}
}

%new
- (void)repeatButtonPressed
{
	if(![[self repeatButton] isHolding])
	{
		id advance = [[[[self response] tracklist] repeatCommand] advance];
		if(advance)
			[%c(MPCPlayerChangeRequest) performRequest: advance completion: nil];
	}
}

%new
- (void)updateButtonIcons: (BOOL)arg
{
	_MPCPlayerShuffleCommand *shuffleCommand = [[[self response] tracklist] shuffleCommand];
	_MPCPlayerRepeatCommand *repeatCommand = [[[self response] tracklist] repeatCommand];

	BOOL supportsShuffle = [shuffleCommand supportsChangeShuffle] || [shuffleCommand supportsAdvanceShuffle];
	BOOL supportsRepeat = [repeatCommand supportsChangeRepeat] || [repeatCommand supportsAdvanceRepeat];
	BOOL tvRemoteButtonIsHidden = ![self tvRemoteButton] || [[self tvRemoteButton] isHidden];
	BOOL languageOptionsButtonIsHidden = ![self languageOptionsButton] || [[self languageOptionsButton] isHidden];
	BOOL shouldShow = supportsShuffle && supportsRepeat && tvRemoteButtonIsHidden && languageOptionsButtonIsHidden;
	
	if(arg)
	{
		long long currentShuffleType = [shuffleCommand currentShuffleType];
		long long currentRepeatType = [repeatCommand currentRepeatType];

		[[self shuffleButton] setImage: shuffleImages[MIN(1, currentShuffleType)] forState: UIControlStateNormal];
		[[self repeatButton] setImage: repeatImages[MIN(2, currentRepeatType)] forState: UIControlStateNormal];
	}

	if(shouldShow != [[self extraButtonsShown] isEqual: @YES])
	{
		[self setExtraButtonsShown: shouldShow ? @YES : @NO];
		[self setNeedsLayout];
	}
}

%new
- (MediaControlsTransportButton*)repeatButton
{
	return (MediaControlsTransportButton*)objc_getAssociatedObject(self, @selector(repeatButton));
}

%new
- (void)setRepeatButton: (MediaControlsTransportButton*)button
{
	objc_setAssociatedObject(self, @selector(repeatButton), button, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%new
- (MediaControlsTransportButton*)shuffleButton
{
	return (MediaControlsTransportButton*)objc_getAssociatedObject(self, @selector(shuffleButton));
}

%new
- (void)setShuffleButton: (MediaControlsTransportButton*)button
{
	objc_setAssociatedObject(self, @selector(shuffleButton), button, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%new
- (id)extraButtonsShown
{
	return (id)objc_getAssociatedObject(self, @selector(extraButtonsShown));
}

%new
- (void)setExtraButtonsShown: (id)arg
{
	objc_setAssociatedObject(self, @selector(extraButtonsShown), arg, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%new
- (id)hasExtraButtons
{
	return (id)objc_getAssociatedObject(self, @selector(hasExtraButtons));
}

%new
- (void)setHasExtraButtons: (id)arg
{
	objc_setAssociatedObject(self, @selector(hasExtraButtons), arg, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%end

void initExtraButtons()
{
	preferences = [MusicPreferences sharedInstance];

	%init;
}