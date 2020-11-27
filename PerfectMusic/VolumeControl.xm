#import "MediaRemote.h"
#import "VolumeControl.h"
#import "MusicPreferences.h"

static const float VOLUME_STEP =  1.0 / 16.0;

static NSTimer *forwardTimer;
static NSTimer *backTimer;

static BOOL shouldSwap = NO;
static BOOL shouldControlPause = NO;

static void produceMediumVibration()
{
	UIImpactFeedbackGenerator *gen = [[UIImpactFeedbackGenerator alloc] initWithStyle: UIImpactFeedbackStyleMedium];
	[gen prepare];
	[gen impactOccurred];
}

// Used code by @gilshahar7: https://github.com/gilshahar7/VolumeSongSkipper113

%group controlMediaWithVolumeButtonsGroup

	%hook SpringBoard

	- (BOOL)_handlePhysicalButtonEvent: (UIPressesEvent*)pressesEvent
	{
		if([[[self _accessibilityFrontMostApplication] bundleIdentifier] isEqualToString: @"com.apple.camera"])
			return %orig;

		BOOL hasUp = NO;
		CGFloat upForce;
		BOOL hasDown = NO;
		CGFloat downForce;
		
		for(UIPress* press in [[pressesEvent allPresses] allObjects])
		{
			if([press type] == 102)
			{
				hasUp = YES;
				upForce = [press force];
			}
			if([press type] == 103)
			{
				hasDown = YES;
				downForce = [press force];
			}
		}

		if(hasUp && hasDown) 
		{
			if(upForce == 1 && downForce == 1)
			{
				MRMediaRemoteSendCommand(kMRTogglePlayPause, nil);
				produceMediumVibration();
			}
		}
		else if(hasUp || hasDown)
		{
			UIPress *press = [[pressesEvent allPresses] allObjects][0];
			long pressType = [press type];
			CGFloat pressForce = [press force];

			if(pressType == 102 && pressForce == 0) //VOLUME UP RELEASED
			{
				backTimer = [NSTimer scheduledTimerWithTimeInterval: 0.5 target: self selector: @selector(invalidateBack) userInfo: nil repeats: NO];
				if(forwardTimer != nil)
				{
					MRMediaRemoteSendCommand(kMRNextTrack, nil);
					produceMediumVibration();

					[forwardTimer invalidate];
					forwardTimer = nil;
				}
			}

			if(pressType == 103 && pressForce == 0) //VOLUME DOWN RELEASED
			{
				forwardTimer = [NSTimer scheduledTimerWithTimeInterval: 0.5 target: self selector: @selector(invalidateForward) userInfo: nil repeats: NO];
				if(backTimer != nil)
				{
					MRMediaRemoteSendCommand(kMRPreviousTrack, nil);
					produceMediumVibration();

					[backTimer invalidate];
					backTimer = nil;
				}
			}
		}
		return %orig;
	}

	%new
	- (void)invalidateForward
	{
		[forwardTimer invalidate];
		forwardTimer = nil;
	}

	%new
	- (void)invalidateBack
	{
		[backTimer invalidate];
		backTimer = nil;
	}

	%end

%end

%group swapVolumeButtonsGroup

	%hook SBVolumeControl

	- (BOOL)_isVolumeHUDVisibleOrFading
	{
		UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
		if (deviceOrientation == UIDeviceOrientationLandscapeLeft
		|| deviceOrientation == UIDeviceOrientationPortraitUpsideDown
		|| deviceOrientation == UIDeviceOrientationFaceUp && shouldSwap
		|| deviceOrientation == UIDeviceOrientationFaceDown && shouldSwap)
			shouldSwap = YES;
		else
			shouldSwap = NO;

		return %orig;
	}

	%end

%end

%group swapBasedOnOrientationAndPauseOnZeroGroup

	%hook SBVolumeControl

	- (void)increaseVolume
	{
		if(shouldSwap)
		{
			[self changeVolumeByDelta: -VOLUME_STEP];

			if(shouldControlPause && [self _effectiveVolume] < 0.1 && ![[%c(SBMediaController) sharedInstance] isPaused])
				[[%c(SBMediaController) sharedInstance] pauseForEventSource: 0];
		}
		else
		{
			%orig;

			if(shouldControlPause && [self _effectiveVolume] < 0.1 && [[%c(SBMediaController) sharedInstance] isPaused])
				[[%c(SBMediaController) sharedInstance] playForEventSource: 0];
		}

	}

	- (void)decreaseVolume
	{
		if(shouldSwap)
		{
			[self changeVolumeByDelta: VOLUME_STEP];

			if(shouldControlPause && [self _effectiveVolume] < 0.1 && [[%c(SBMediaController) sharedInstance] isPaused])
				[[%c(SBMediaController) sharedInstance] playForEventSource: 0];
		}
		else
		{
			%orig;

			if(shouldControlPause && [self _effectiveVolume] < 0.1 && ![[%c(SBMediaController) sharedInstance] isPaused])
				[[%c(SBMediaController) sharedInstance] pauseForEventSource: 0];
		}
	}

	%end

%end

void initVolumeControl()
{
	MusicPreferences *preferences = [MusicPreferences sharedInstance];

	if([preferences enabledMediaControlWithVolumeButtons] || [preferences swapVolumeButtonsBasedOnOrientation])
	{
		shouldControlPause = [preferences pauseMusicOnZeroVolume];

		if(shouldControlPause || [preferences swapVolumeButtonsBasedOnOrientation])
			%init(swapBasedOnOrientationAndPauseOnZeroGroup);

		if([preferences enabledMediaControlWithVolumeButtons])
			%init(controlMediaWithVolumeButtonsGroup);

		if([preferences swapVolumeButtonsBasedOnOrientation])
			%init(swapVolumeButtonsGroup);
	}
}