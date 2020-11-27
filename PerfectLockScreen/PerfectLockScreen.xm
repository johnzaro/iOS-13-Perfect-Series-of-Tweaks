#import "PerfectLockScreen.h"
#import <Cephei/HBPreferences.h>
#import "SparkColourPickerUtils.h"

#define IS_iPAD ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

static SBFLockScreenDateView *lockScreenDateView;

static BOOL isDNDActive;
static BOOL isRingerSilent;

static HBPreferences *pref;
static BOOL enabled;
static BOOL removeCCGrabber;
static BOOL doNotWakeWhenFlashlight;
static BOOL noDragOnMediaPlayer;
static BOOL noSwipeToUnlockText;
static BOOL autoRetryFaceID;
static BOOL roundedCorners;
static BOOL enableAutoRotate;
static BOOL hideBatteryChargingAnimation;
static BOOL enableCustomCarrier;
static NSString *customCarrier;
static BOOL hideLockIcon;
static BOOL hideTodayView;
static BOOL hideDate;
static BOOL disableSwipeForCamera;
static BOOL disableClickForCamera;
static BOOL showQuickActionButtons;
static NSInteger quickActionButtonsExtraOffset;
static BOOL quickActionsTransparentBackground;
static BOOL hideFlashlightButton;
static BOOL hideCameraButton;

static BOOL showDNDIndicator;
static BOOL enableDNDTintColor;
static UIColor *dndTintColor;
static BOOL enableDNDGlow;
static UIColor *dndGlowColor;
static BOOL showSilentIndicator;
static BOOL enableSilentTintColor;
static UIColor *silentTintColor;
static BOOL enableSilentGlow;
static UIColor *silentGlowColor;
static double statusIndicatorLocationX;
static double statusIndicatorLocationY;
static long statusIndicatorSize;

CGFloat screenWidth, screenHeight;
CGFloat quickButtonsSize;

// ------------------------------ REMOVE CC GRABBER ------------------------------

%group removeCCGrabberGroup

	%hook CSTeachableMomentsContainerView

	- (void)_layoutControlCenterGrabberAndGlyph
	{

	}

	%end

%end

// ------------------------------ DO NOT WAKE DISPLAY IF FLASHLIGHT IS ON ------------------------------

%group doNotWakeWhenFlashlightGroup

	// Original code by @CPDigitalDarkroom: https://github.com/CPDigitalDarkroom/NoFlashlightWake

	%hook SBLiftToWakeManager

	- (void)liftToWakeController: (id)arg1 didObserveTransition: (long long)arg2 deviceOrientation: (long long)arg3
	{
		if(!([[%c(SBUIFlashlightController) sharedInstance] level] > 0)) %orig;
	}

	%end

	%hook SBTapToWakeController

	- (void)tapToWakeDidRecognize: (id)arg1
	{
		if(!([[%c(SBUIFlashlightController) sharedInstance] level] > 0)) %orig;
	}

	%end

%end

// ------------------------------ DISABLE LOCKSCREEN DRAGGING ON THE MEDIA PLAYER ------------------------------

%group noDragOnMediaPlayerGroup

	// Original code by @KritantaDev: https://github.com/KritantaDev/nomediadrag

	%hook MRPlatterViewController

	- (void)viewDidLoad
	{
		%orig;
		[self.view setValue: @NO forKey: @"deliversTouchesForGesturesToSuperview"];	
	}

	%end

%end

// ------------------------------ HIDE "SWIPE UP TO UNLOCK" TEXT ------------------------------

%group noSwipeToUnlockTextGroup

	%hook CSTeachableMomentsContainerView

	- (void)setCallToActionLabel: (id)arg
	{
		
	}

	%end

%end

// ------------------------------ AUTO RETRY FACEID ------------------------------

%group autoRetryFaceIDGroup

	// Original code by @gilshahar7: https://github.com/gilshahar7/PearlRetry

	%hook SBDashBoardPearlUnlockBehavior

	- (void)_handlePearlFailure
	{
		%orig;
		
		[[%c(SBUIBiometricResource) sharedInstance] noteScreenDidTurnOff];
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(NSEC_PER_SEC)), dispatch_get_main_queue(), 
		^{
			[[%c(SBUIBiometricResource) sharedInstance] noteScreenWillTurnOn];
		});
	}

	%end

%end

// ------------------------------ ROUNDED CORNERS ------------------------------

%group roundedCornersGroup

	%hook SBCoverSheetPanelBackgroundContainerView

	- (void)layoutSubviews
	{
		[self.layer setMasksToBounds: YES];
		[self _setCornerRadius: [[[self window] screen] _displayCornerRadius]];
	}

	%end

%end

// ------------------------------ QUICK ACTIONS TRANSPARENT BACKGROUND ------------------------------

%group quickActionsTransparentBackgroundGroup

	%hook UIVisualEffectView

	- (void)setBackgroundEffects: (id)arg
	{

	}

	%end

%end

// ------------------------------ AUTO ROTATE ------------------------------

%group enableAutoRotateGroup

	%hook CSCoverSheetViewController

	- (BOOL)shouldAutorotate
	{
		return enableAutoRotate;
	}

	%end

%end

// ------------------------------ HIDE BATTERY CHARGING ANIMATION ------------------------------

%group hideBatteryChargingAnimationGroup

	%hook CSCoverSheetViewController

	- (void)_transitionChargingViewToVisible: (BOOL)arg1 showBattery: (BOOL)arg2 animated: (BOOL)arg3
	{
		%orig(NO, arg2, arg3);
	}

	%end

%end

// ------------------------------ CUSTOM CARRIER TEXT ------------------------------

%group customCarrierGroup

	%hook _UIStatusBarDataCellularEntry

	- (void)setString: (NSString*)arg
	{
		%orig(customCarrier);
	}

	%end

%end

// ------------------------- HIDE LOCK ICON -------------------------

%group hideLockIconGroup

	%hook SBUIProudLockIconView
	
	- (void)layoutSubviews
	{
		[self setHidden: YES];
	}

	%end

%end

// ------------------------------ HIDE TODAY VIEW ------------------------------

%group hideTodayViewGroup

	%hook SBMainDisplayPolicyAggregator

	- (BOOL)_allowsCapabilityLockScreenTodayViewWithExplanation: (id*)arg1
	{
		return NO;
	}

	%end

%end

// ------------------------------ HIDE DATE ------------------------------

%group hideDateGroup

	%hook SBFLockScreenDateView

	- (void)setContentAlpha: (double)arg1 withSubtitleVisible: (BOOL)arg2
	{
		%orig(1, NO);
	}

	%end

%end

// ------------------------------ DISABLE SWIPE FOR CAMERA ------------------------------

%group disableCameraGroup

	%hook SBMainDisplayPolicyAggregator

	- (BOOL)_allowsCapabilityLockScreenCameraWithExplanation: (id*)arg1
	{
		return !disableSwipeForCamera;
	}

	%end

	%hook CSQuickActionsViewController
	
	- (BOOL)allowsCameraPress
	{
		return !disableClickForCamera;
	}

	%end

	%hook UICoverSheetButton

	- (void)clickInteractionDidClickUp: (id)arg1
	{
		if([[self localizedAccessoryTitle] isEqualToString: @"Press for Camera"])
		{
			dispatch_async(dispatch_get_main_queue(),
			^{
				[[UIApplication sharedApplication] launchApplicationWithIdentifier: @"com.apple.camera" suspended: NO];
				[[%c(SBLockScreenManager) sharedInstance] unlockUIFromSource: 2 withOptions: 0];
			});
		}

		%orig;
	}

	%end

%end

// ------------------------------ SHOW QUICK ACTION BUTTONS ------------------------------

%group showQuickActionButtonsGroup

	%hook SpringBoard

	- (void)applicationDidFinishLaunching: (id)application
	{
		%orig;

		CGRect referenceBounds = [[UIScreen mainScreen] _referenceBounds];
		screenWidth = referenceBounds.size.width;
		screenHeight = referenceBounds.size.height;
		if(screenHeight > 812) quickButtonsSize = 58;
		else if(screenHeight >= 736) quickButtonsSize = 50;
		else quickButtonsSize = 42;
	}

	%end

	%hook CSQuickActionsViewController

	+ (BOOL)deviceSupportsButtons
	{
		return YES;
	}

	- (BOOL)hasCamera
	{
		return YES;
	}

	- (BOOL)hasFlashlight
	{
		return YES;
	}

	%end

	%hook CSQuickActionsView

	- (void)_layoutQuickActionButtons
	{
		UIEdgeInsets insets = [self _buttonOutsets];
		[[self flashlightButton] setEdgeInsets: insets];
		[[self cameraButton] setEdgeInsets: insets];

		UIDeviceOrientation orientation = [[UIApplication sharedApplication] _frontMostAppOrientation];
		BOOL rightToLeftDirection = [[UIApplication sharedApplication] userInterfaceLayoutDirection] == UIUserInterfaceLayoutDirectionRightToLeft;
		CGFloat buttonWidth = quickButtonsSize + insets.right + insets.left;
		CGFloat buttonHeight = quickButtonsSize + insets.top + insets.bottom;
		CGFloat xOffset = rightToLeftDirection ? insets.right : insets.left;
		CGFloat rightOffsetX, yOffset;
		CGRect leftRect, rightRect;
		if(orientation == UIDeviceOrientationLandscapeRight || orientation == UIDeviceOrientationLandscapeLeft)
		{
			yOffset = screenWidth - buttonHeight - insets.bottom;
			rightOffsetX = screenHeight - xOffset - buttonWidth;
		}
		else
		{
			yOffset = screenHeight - buttonHeight - insets.bottom;
			rightOffsetX = screenWidth - xOffset - buttonWidth;
		}
		leftRect = CGRectMake(xOffset + quickActionButtonsExtraOffset, yOffset - quickActionButtonsExtraOffset, buttonWidth, buttonHeight);
		rightRect = CGRectMake(rightOffsetX - quickActionButtonsExtraOffset, yOffset - quickActionButtonsExtraOffset, buttonWidth, buttonHeight);
		if(rightToLeftDirection)
		{
			[[self cameraButton] setFrame: leftRect];
			[[self flashlightButton] setFrame: rightRect];
		}
		else
		{
			[[self flashlightButton] setFrame: leftRect];
			[[self cameraButton] setFrame: rightRect];
		}
	}

	%end

%end

// ------------------------- HIDE QUICK ACTION BUTTONS -------------------------

%group hideQuickActionButtonsGroup

	%hook CSQuickActionsButton

	- (void)didMoveToWindow
	{
		%orig;

		if([self type] == 0 && hideCameraButton) [self setHidden: YES];
		if([self type] == 1 && hideFlashlightButton) [self setHidden: YES];
	}

	%end

%end

// ------------------------- SHOW STATUS INDICATORS -------------------------

%group showIndicatorGroup

	%hook DNDState

	- (BOOL)isActive
	{
		isDNDActive = %orig;
		return isDNDActive;
	}
	
	- (void)setActive: (BOOL)arg1
	{
		%orig;

		isDNDActive = arg1;
		[lockScreenDateView updateIndicatorImageView];
	}

	%end

	%hook SBRingerControl

	- (void)setRingerMuted: (BOOL)arg1
	{
		%orig;

		isRingerSilent = arg1;
		[lockScreenDateView updateIndicatorImageView];
	}

	%end

	%hook SBFLockScreenDateView

	%property(nonatomic, retain) UIImageView *dndImageView;
	%property(nonatomic, retain) UIImageView *silentImageView;

	- (id)initWithFrame: (CGRect)arg1
	{
		lockScreenDateView = %orig;

		if(showDNDIndicator)
		{
			[self setDndImageView: [[UIImageView alloc] initWithFrame: CGRectMake(statusIndicatorLocationX, statusIndicatorLocationY, statusIndicatorSize, statusIndicatorSize)]];
			[[self dndImageView] setImage: [[UIImage imageWithContentsOfFile: @"/Library/PreferenceBundles/PerfectLockScreen13Prefs.bundle/dnd.png"] imageWithRenderingMode: UIImageRenderingModeAlwaysTemplate]];
			[[self dndImageView] setContentMode: UIViewContentModeScaleAspectFit];
			
			if(enableDNDTintColor)
				[[self dndImageView] setTintColor: dndTintColor];
			if(enableDNDGlow)
			{
				[[[self dndImageView] layer] setShadowOffset: CGSizeZero];
				[[[self dndImageView] layer] setShadowColor: dndGlowColor.CGColor];
				[[[self dndImageView] layer] setShadowRadius: statusIndicatorSize / 10];
				[[[self dndImageView] layer] setShadowOpacity: 1.0];
			}
		}	
		if(showSilentIndicator)
		{
			[self setSilentImageView: [[UIImageView alloc] initWithFrame: CGRectMake(statusIndicatorLocationX, statusIndicatorLocationY, statusIndicatorSize, statusIndicatorSize)]];
			[[self silentImageView] setImage: [[UIImage imageWithContentsOfFile: @"/Library/PreferenceBundles/PerfectLockScreen13Prefs.bundle/vibration.png"] imageWithRenderingMode: UIImageRenderingModeAlwaysTemplate]];
			[[self silentImageView] setContentMode: UIViewContentModeScaleAspectFit];
			
			if(enableSilentTintColor)
				[[self silentImageView] setTintColor: silentTintColor];
			if(enableSilentGlow)
			{
				[[[self silentImageView] layer] setShadowOffset: CGSizeZero];
				[[[self silentImageView] layer] setShadowColor: silentGlowColor.CGColor];
				[[[self silentImageView] layer] setShadowRadius: statusIndicatorSize / 10];
				[[[self silentImageView] layer] setShadowOpacity: 1.0];
			}
		}	

		return lockScreenDateView;
	}

	- (void)layoutSubviews
	{
		%orig;

		[self updateIndicatorImageView];
	}

	%new
	- (void)updateIndicatorImageView
	{
		if([self dndImageView])
			[[self dndImageView] removeFromSuperview];
		if([self silentImageView])
			[[self silentImageView] removeFromSuperview];

		if(isDNDActive && showDNDIndicator)
			[self addSubview: [self dndImageView]];
		else if(isRingerSilent && showSilentIndicator)
			[self addSubview: [self silentImageView]];
	}

	%end

%end

%ctor
{
	pref = [[HBPreferences alloc] initWithIdentifier: @"com.johnzaro.perfectlockscreen13prefs"];
	[pref registerDefaults:
	@{
		@"enabled": @NO,
		@"removeCCGrabber": @NO,
		@"doNotWakeWhenFlashlight": @NO,
		@"noDragOnMediaPlayer": @NO,
		@"noSwipeToUnlockText": @NO,
		@"autoRetryFaceID": @NO,
		@"roundedCorners": @NO,
		@"quickActionsTransparentBackground": @NO,
		@"enableAutoRotate": @NO,
		@"hideBatteryChargingAnimation": @NO,
		@"enableCustomCarrier": @NO,
		@"customCarrier": @"",
		@"hideLockIcon": @NO,
		@"hideTodayView": @NO,
		@"hideDate": @NO,
		@"disableSwipeForCamera": @NO,
		@"disableClickForCamera": @NO,

		@"showQuickActionButtons": @NO,
		@"quickActionButtonsExtraOffset": @0,
		@"quickActionsTransparentBackground": @NO,
		@"hideFlashlightButton": @NO,
		@"hideCameraButton": @NO,

		@"showDNDIndicator": @NO,
		@"enableDNDTintColor": @NO,
		@"enableDNDGlow": @NO,
		@"showSilentIndicator": @NO,
		@"enableSilentTintColor": @NO,
		@"enableSilentGlow": @NO,
		@"statusIndicatorLocationX": @285,
		@"statusIndicatorLocationY": @30,
		@"statusIndicatorSize": @40
	}];
	
	enabled = [pref boolForKey: @"enabled"];
	if(enabled)
	{
		removeCCGrabber = [pref boolForKey: @"removeCCGrabber"];
		doNotWakeWhenFlashlight = [pref boolForKey: @"doNotWakeWhenFlashlight"];
		noDragOnMediaPlayer = [pref boolForKey: @"noDragOnMediaPlayer"];
		noSwipeToUnlockText = [pref boolForKey: @"noSwipeToUnlockText"];
		autoRetryFaceID = [pref boolForKey: @"autoRetryFaceID"];
		roundedCorners = [pref boolForKey: @"roundedCorners"];
		quickActionsTransparentBackground = [pref boolForKey: @"quickActionsTransparentBackground"];
		enableAutoRotate = [pref boolForKey: @"enableAutoRotate"];
		hideBatteryChargingAnimation = [pref boolForKey: @"hideBatteryChargingAnimation"];
		enableCustomCarrier = [pref boolForKey: @"enableCustomCarrier"];
		customCarrier = [pref objectForKey: @"customCarrier"];
		hideLockIcon = [pref boolForKey: @"hideLockIcon"];
		hideTodayView = [pref boolForKey: @"hideTodayView"];
		hideDate = [pref boolForKey: @"hideDate"];
		disableSwipeForCamera = [pref boolForKey: @"disableSwipeForCamera"];
		disableClickForCamera = [pref boolForKey: @"disableClickForCamera"];
		showQuickActionButtons = [pref boolForKey: @"showQuickActionButtons"];
		quickActionsTransparentBackground = [pref boolForKey: @"quickActionsTransparentBackground"];
		hideFlashlightButton = [pref boolForKey: @"hideFlashlightButton"];
		hideCameraButton = [pref boolForKey: @"hideCameraButton"];

		%init(enableAutoRotateGroup);
		
		if(removeCCGrabber)
			%init(removeCCGrabberGroup);
		if(doNotWakeWhenFlashlight)
			%init(doNotWakeWhenFlashlightGroup);
		if(noDragOnMediaPlayer)
			%init(noDragOnMediaPlayerGroup);
		if(noSwipeToUnlockText)
			%init(noSwipeToUnlockTextGroup);
		if(autoRetryFaceID)
			%init(autoRetryFaceIDGroup);
		if(roundedCorners)
			%init(roundedCornersGroup);
		if(hideBatteryChargingAnimation)
			%init(hideBatteryChargingAnimationGroup);
		if(enableCustomCarrier)
			%init(customCarrierGroup);
		if(hideLockIcon)
			%init(hideLockIconGroup);
		if(hideTodayView)
			%init(hideTodayViewGroup);
		if(hideDate)
			%init(hideDateGroup);

		if(disableSwipeForCamera || disableClickForCamera)
			%init(disableCameraGroup);
		if(showQuickActionButtons)
		{
			quickActionButtonsExtraOffset = [pref integerForKey: @"quickActionButtonsExtraOffset"];
			%init(showQuickActionButtonsGroup);
		}
		if(quickActionsTransparentBackground)
			%init(quickActionsTransparentBackgroundGroup);
		if(hideFlashlightButton || hideCameraButton)
			%init(hideQuickActionButtonsGroup);

		showDNDIndicator = [pref boolForKey: @"showDNDIndicator"];
		showSilentIndicator = [pref boolForKey: @"showSilentIndicator"];
		
		if(showDNDIndicator || showSilentIndicator)
		{
			statusIndicatorLocationX = [pref floatForKey: @"statusIndicatorLocationX"];
			statusIndicatorLocationY = [pref floatForKey: @"statusIndicatorLocationY"];
			statusIndicatorSize = [pref integerForKey: @"statusIndicatorSize"];

			enableDNDGlow = [pref boolForKey: @"enableDNDGlow"];
			enableSilentGlow = [pref boolForKey: @"enableSilentGlow"];
			enableDNDTintColor = [pref boolForKey: @"enableDNDTintColor"];
			enableSilentTintColor = [pref boolForKey: @"enableSilentTintColor"];

			if(showDNDIndicator && (enableDNDTintColor || enableDNDGlow) || showSilentIndicator && (enableSilentTintColor || enableSilentGlow))
			{
				NSDictionary *preferencesDictionary = [NSDictionary dictionaryWithContentsOfFile: @"/var/mobile/Library/Preferences/com.johnzaro.perfectlockscreen13prefs.colors.plist"];

				dndTintColor = [SparkColourPickerUtils colourWithString: [preferencesDictionary objectForKey: @"dndTintColor"] withFallback: @"#9b59b6"];
				dndGlowColor = [SparkColourPickerUtils colourWithString: [preferencesDictionary objectForKey: @"dndGlowColor"] withFallback: @"#9b59b6"];
				silentTintColor = [SparkColourPickerUtils colourWithString: [preferencesDictionary objectForKey: @"silentTintColor"] withFallback: @"#ffffff"];
				silentGlowColor = [SparkColourPickerUtils colourWithString: [preferencesDictionary objectForKey: @"silentGlowColor"] withFallback: @"#ffffff"];
			}

			%init(showIndicatorGroup);
		}
	}
}