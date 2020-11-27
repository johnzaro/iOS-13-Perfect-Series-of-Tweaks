#import "PerfectNetworkSpeedInfo.h"
#import "SparkColourPickerUtils.h"
#import "SparkAppList.h"
#import <Cephei/HBPreferences.h>
#import <ifaddrs.h>
#import <net/if.h>

#define DegreesToRadians(degrees) (degrees * M_PI / 180)

static const long KILOBITS = 1000;
static const long MEGABITS = 1000000;
static const long KILOBYTES = 1 << 10;
static const long MEGABYTES = 1 << 20;

__strong static PerfectNetworkSpeedInfo *networkSpeedObject;

static BOOL shouldUpdateSpeedLabel;
static long oldUpSpeed = 0, oldDownSpeed = 0;
typedef struct
{
    uint32_t inputBytes;
    uint32_t outputBytes;
} UpDownBytes;

static HBPreferences *pref;
static BOOL enabled;
static BOOL showOnLockScreen;
static BOOL showOnlyOnLockScreen;
static BOOL showOnControlCenter;
static BOOL hideOnFullScreen;
static BOOL hideOnLandscape;
static BOOL hideOnAppSwitcherFolder;
static BOOL notchlessSupport;
static NSInteger separateSpeeds;
static BOOL showDownloadSpeedFirst;
static BOOL showSecondSpeedInNewLine;
static BOOL showUploadSpeed;
static NSString *uploadPrefix;
static BOOL showDownloadSpeed;
static NSString *downloadPrefix;
static NSString *separator;
static NSInteger dataUnit;
static NSInteger minimumUnit;
static BOOL backgroundColorEnabled;
static NSInteger margin;
static CGFloat backgroundCornerRadius;
static BOOL customBackgroundColorEnabled;
static UIColor *customBackgroundColor;
static BOOL showAlways;
static double portraitX;
static double portraitY;
static double landscapeX;
static double landscapeY;
static BOOL followDeviceOrientation;
static BOOL animateMovement;
static double width;
static double height;
static long fontSize;
static BOOL boldFont;
static BOOL customTextColorEnabled;
static UIColor *customTextColor;
static long alignment;
static double updateInterval;
static BOOL enableDoubleTap;
static NSString *doubleTapIdentifier;
static BOOL enableHold;
static NSString *holdIdentifier;
static BOOL enableBlackListedApps;
static NSArray *blackListedApps;

static double screenWidth;
static double screenHeight;
static UIDeviceOrientation orientationOld;
static UIDeviceOrientation deviceOrientation;
static BOOL isBlacklistedAppInFront = NO;
static BOOL shouldHideBasedOnOrientation = NO;
static BOOL isOnLandscape;
static BOOL isPeepStatusBarHidden = NO;
static BOOL isStatusBarHidden = NO;
static BOOL isAppSwitcherOpen = NO;
static BOOL isFolderOpen = NO;

// Got some help from similar network speed tweaks by julioverne & n3d1117

NSString* formatSpeed(long bytes)
{
	if(dataUnit == 0) // BYTES
	{
		if(bytes < KILOBYTES)
		{
			if(minimumUnit == 0)
				return [NSString stringWithFormat: @"%ldB/s", bytes];
			else
				return @"0KB/s";
		}
		else if(bytes < MEGABYTES) return [NSString stringWithFormat: @"%.0fKB/s", (double)bytes / KILOBYTES];
		else return [NSString stringWithFormat: @"%.2fMB/s", (double)bytes / MEGABYTES];
	}
	else // BITS
	{
		if(bytes < KILOBITS)
		{
			if(minimumUnit == 0)
				return [NSString stringWithFormat: @"%ldb/s", bytes];
			else
				return @"0Kb/s";
		}
		else if(bytes < MEGABITS) return [NSString stringWithFormat: @"%.0fKb/s", (double)bytes / KILOBITS];
		else return [NSString stringWithFormat: @"%.2fMb/s", (double)bytes / MEGABITS];
	}
}

UpDownBytes getUpDownBytes()
{
	struct ifaddrs *ifa_list = 0, *ifa;
	UpDownBytes upDownBytes;
	upDownBytes.inputBytes = 0;
	upDownBytes.outputBytes = 0;
	
	if((getifaddrs(&ifa_list) < 0) || !ifa_list || ifa_list == 0)
		return upDownBytes;

	for(ifa = ifa_list; ifa; ifa = ifa->ifa_next)
	{
		if(ifa->ifa_addr == NULL
		|| AF_LINK != ifa->ifa_addr->sa_family
		|| (!(ifa->ifa_flags & IFF_UP) && !(ifa->ifa_flags & IFF_RUNNING))
		|| ifa->ifa_data == NULL || ifa->ifa_data == 0
		|| strstr(ifa->ifa_name, "lo0")
		|| strstr(ifa->ifa_name, "utun"))
			continue;
		
		struct if_data *if_data = (struct if_data *)ifa->ifa_data;

		upDownBytes.inputBytes += if_data->ifi_ibytes;
		upDownBytes.outputBytes += if_data->ifi_obytes;
	}
	if(ifa_list)
		freeifaddrs(ifa_list);

	return upDownBytes;
}

static NSMutableString* formattedString()
{
	NSMutableString* mutableString = [[NSMutableString alloc] init];
	
	UpDownBytes upDownBytes = getUpDownBytes();
	long upDiff = (upDownBytes.outputBytes - oldUpSpeed) / updateInterval;
	long downDiff = (upDownBytes.inputBytes - oldDownSpeed) / updateInterval;
	oldUpSpeed = upDownBytes.outputBytes;
	oldDownSpeed = upDownBytes.inputBytes;

	if(!showAlways && (upDiff < 2 * KILOBYTES && downDiff < 2 * KILOBYTES))
	{
		shouldUpdateSpeedLabel = NO;
		return nil;
	}
	else shouldUpdateSpeedLabel = YES;

	if(dataUnit == 1) // BITS
	{
		upDiff *= 8;
		downDiff *= 8;
	}

	if(upDiff > 50 * MEGABYTES && downDiff > 50 * MEGABYTES)
	{
		upDiff = 0;
		downDiff = 0;
	}

	if(separateSpeeds == 0)
	{
		if(showDownloadSpeedFirst)
		{
			if(showDownloadSpeed) [mutableString appendString: [NSString stringWithFormat: @"%@%@", downloadPrefix, formatSpeed(downDiff)]];
			if(showUploadSpeed)
			{
				if([mutableString length] > 0)
				{
					if(showSecondSpeedInNewLine) [mutableString appendString: @"\n"];
					else [mutableString appendString: separator];
				}
				[mutableString appendString: [NSString stringWithFormat: @"%@%@", uploadPrefix, formatSpeed(upDiff)]];
			}
		}
		else
		{
			if(showUploadSpeed) [mutableString appendString: [NSString stringWithFormat: @"%@%@", uploadPrefix, formatSpeed(upDiff)]];
			if(showDownloadSpeed)
			{
				if([mutableString length] > 0)
				{
					if(showSecondSpeedInNewLine) [mutableString appendString: @"\n"];
					else [mutableString appendString: separator];
				}
				[mutableString appendString: [NSString stringWithFormat: @"%@%@", downloadPrefix, formatSpeed(downDiff)]];
			}
		}
	}
	else
	{
		long totalSpeed = upDiff + downDiff;
		if(dataUnit == 0 && totalSpeed >= KILOBYTES || dataUnit == 1 && totalSpeed >= KILOBITS)
		{
			if(upDiff > downDiff)
				[mutableString appendString: uploadPrefix];
			else
				[mutableString appendString: downloadPrefix];
		}
		[mutableString appendString: formatSpeed(totalSpeed)];
	}
	
	return [mutableString copy];
}

static void orientationChanged()
{
	deviceOrientation = [[UIApplication sharedApplication] _frontMostAppOrientation];
	if(deviceOrientation == UIDeviceOrientationLandscapeRight || deviceOrientation == UIDeviceOrientationLandscapeLeft)
		isOnLandscape = YES;
	else
		isOnLandscape = NO;

	if((hideOnLandscape || followDeviceOrientation) && networkSpeedObject) 
		[networkSpeedObject updateOrientation];
}

static void loadDeviceScreenDimensions()
{
	screenWidth = [[UIScreen mainScreen] _referenceBounds].size.width;
	screenHeight = [[UIScreen mainScreen] _referenceBounds].size.height;
}

@implementation PerfectNetworkSpeedInfo

	- (id)init
	{
		self = [super init];
		if(self)
		{
			networkSpeedLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, 0, 0)];
			[networkSpeedLabel setAdjustsFontSizeToFitWidth: YES];

			UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(openDoubleTapApp)];
			[tapGestureRecognizer setNumberOfTapsRequired: 2];

			UILongPressGestureRecognizer *holdGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget: self action: @selector(openHoldApp)];

			networkSpeedWindow = [[UIWindow alloc] initWithFrame: CGRectMake(0, 0, 0, 0)];
			[networkSpeedWindow _setSecure: YES];
			[[networkSpeedWindow layer] setAnchorPoint: CGPointZero];
			[networkSpeedWindow addSubview: networkSpeedLabel];
			[networkSpeedWindow addGestureRecognizer: tapGestureRecognizer];
			[networkSpeedWindow addGestureRecognizer: holdGestureRecognizer];

			coverSheetPresentationManagerInstance = [%c(SBCoverSheetPresentationManager) sharedInstance];
			controlCenterControllerInstance = [%c(SBControlCenterController) sharedInstance];

			deviceOrientation = [[UIApplication sharedApplication] _frontMostAppOrientation];

			backupForegroundColor = [UIColor whiteColor];
			backupBackgroundColor = [[UIColor blackColor] colorWithAlphaComponent: 0.5];
			[self updateFrame];

			[NSTimer scheduledTimerWithTimeInterval: updateInterval target: self selector: @selector(updateText) userInfo: nil repeats: YES];

			CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)&orientationChanged, CFSTR("com.apple.springboard.screenchanged"), NULL, 0);
			CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(), NULL, (CFNotificationCallback)&orientationChanged, CFSTR("UIWindowDidRotateNotification"), NULL, CFNotificationSuspensionBehaviorCoalesce);
		}
		return self;
	}

	- (void)updateFrame
	{
		[NSObject cancelPreviousPerformRequestsWithTarget: self selector: @selector(_updateFrame) object: nil];
		[self performSelector: @selector(_updateFrame) withObject: nil afterDelay: 0.3];
	}

	- (void)_updateFrame
	{
		orientationOld = nil;

		if(notchlessSupport)
			[networkSpeedWindow setWindowLevel: 100000];
		else
			[networkSpeedWindow setWindowLevel: 1075];
		
		if(!backgroundColorEnabled)
			[networkSpeedWindow setBackgroundColor: [UIColor clearColor]];
		else
		{
			if(customBackgroundColorEnabled)
				[networkSpeedWindow setBackgroundColor: customBackgroundColor];
			else
				[networkSpeedWindow setBackgroundColor: backupBackgroundColor];

			[[networkSpeedWindow layer] setCornerRadius: backgroundCornerRadius];
		}

		[self updatePerfectNetworkSpeedInfoLabelProperties];
		[self updatePerfectNetworkSpeedInfoLabelSize];
		[self updateOrientation];
	}

	- (void)updatePerfectNetworkSpeedInfoLabelProperties
	{
		if(boldFont) [networkSpeedLabel setFont: [UIFont boldSystemFontOfSize: fontSize]];
		else [networkSpeedLabel setFont: [UIFont systemFontOfSize: fontSize]];

		[networkSpeedLabel setNumberOfLines: showSecondSpeedInNewLine ? 2 : 1];
		[networkSpeedLabel setTextAlignment: alignment];

		if(customTextColorEnabled)
			[networkSpeedLabel setTextColor: customTextColor];
		else
			[networkSpeedLabel setTextColor: backupForegroundColor];
	}

	- (void)updatePerfectNetworkSpeedInfoLabelSize
	{
		CGRect frame = [networkSpeedLabel frame];
		frame.origin.x = margin;
		frame.origin.y = margin;
		frame.size.width = width - 2 * margin;
		frame.size.height = height - 2 * margin;
		[networkSpeedLabel setFrame: frame];
	}

	- (void)updateOrientation
	{
		shouldHideBasedOnOrientation = hideOnLandscape && isOnLandscape;
		[self hideIfNeeded];

		if(deviceOrientation == orientationOld)
			return;

		CGAffineTransform newTransform;
		CGRect frame = [networkSpeedWindow frame];

		if(!followDeviceOrientation || deviceOrientation == UIDeviceOrientationPortrait)
		{
			frame.origin.x = portraitX;
			frame.origin.y = portraitY;
			newTransform = CGAffineTransformMakeRotation(DegreesToRadians(0));
		}
		else if(deviceOrientation == UIDeviceOrientationLandscapeLeft)
		{
			frame.origin.x = screenWidth - landscapeY;
			frame.origin.y = landscapeX;
			newTransform = CGAffineTransformMakeRotation(DegreesToRadians(90));
		}
		else if(deviceOrientation == UIDeviceOrientationPortraitUpsideDown)
		{
			frame.origin.x = screenWidth - portraitX;
			frame.origin.y = screenHeight - portraitY;
			newTransform = CGAffineTransformMakeRotation(DegreesToRadians(180));
		}
		else if(deviceOrientation == UIDeviceOrientationLandscapeRight)
		{
			frame.origin.x = landscapeY;
			frame.origin.y = screenHeight - landscapeX;
			newTransform = CGAffineTransformMakeRotation(-DegreesToRadians(90));
		}

		frame.size.width = isOnLandscape && followDeviceOrientation ? height : width;
		frame.size.height = isOnLandscape && followDeviceOrientation ? width : height;

		if(animateMovement)
		{
			[UIView animateWithDuration: 0.3f animations:
			^{
				[networkSpeedWindow setTransform: newTransform];
				[networkSpeedWindow setFrame: frame];
				orientationOld = deviceOrientation;
			} completion: nil];
		}
		else
		{
			[networkSpeedWindow setTransform: newTransform];
			[networkSpeedWindow setFrame: frame];
			orientationOld = deviceOrientation;
		}
	}

	- (void)updateText
	{
		if(networkSpeedWindow && networkSpeedLabel)
		{
			[self hideIfNeeded];
			if(![networkSpeedWindow isHidden])
			{
				NSString *speed = formattedString();
				if(shouldUpdateSpeedLabel && !((isFolderOpen || isAppSwitcherOpen) && hideOnAppSwitcherFolder))
				{
					[networkSpeedWindow setAlpha: 1];
					[networkSpeedLabel setText: speed];
				}
				else
					[networkSpeedWindow setAlpha: 0];
			}
		}
	}

	- (void)updateTextColor: (UIColor*)color
	{
		backupForegroundColor = color;
		CGFloat r;
    	[color getRed: &r green: nil blue: nil alpha: nil];
		if(r == 0 || r == 1)
		{
			if(!customTextColorEnabled)
				[networkSpeedLabel setTextColor: color];

			if(backgroundColorEnabled && !customBackgroundColorEnabled) 
			{
				if(r == 0)
					[networkSpeedWindow setBackgroundColor: [[UIColor whiteColor] colorWithAlphaComponent: 0.5]];
				else
					[networkSpeedWindow setBackgroundColor: [[UIColor blackColor] colorWithAlphaComponent: 0.5]];
				backupBackgroundColor = [networkSpeedWindow backgroundColor];
			}
		}
	}

	- (void)hideIfNeeded
	{
		[networkSpeedWindow setHidden: 
			[coverSheetPresentationManagerInstance _isEffectivelyLocked] 
		 || [coverSheetPresentationManagerInstance isPresented] && !showOnLockScreen
		 || ![coverSheetPresentationManagerInstance isPresented] && showOnlyOnLockScreen
		 || isStatusBarHidden && hideOnFullScreen
		 || [controlCenterControllerInstance isVisible] && !showOnControlCenter
		 || ![coverSheetPresentationManagerInstance isPresented] && (shouldHideBasedOnOrientation || isBlacklistedAppInFront)
		 || isPeepStatusBarHidden];
	}

	- (void)openDoubleTapApp
	{
		if(enableDoubleTap && doubleTapIdentifier)
			[[UIApplication sharedApplication] launchApplicationWithIdentifier: doubleTapIdentifier suspended: NO];
	}

	- (void)openHoldApp
	{
		if(enableHold && holdIdentifier)
			[[UIApplication sharedApplication] launchApplicationWithIdentifier: holdIdentifier suspended: NO];
	}

@end

%hook SpringBoard // load module

- (void)applicationDidFinishLaunching: (id)application
{
	%orig;

	loadDeviceScreenDimensions();
	if(!networkSpeedObject) 
		networkSpeedObject = [[PerfectNetworkSpeedInfo alloc] init];
}

-(void)frontDisplayDidChange: (id)arg1 // check if opened app is blacklisted
{
	%orig;

	NSString *currentApp = [(SBApplication*)[self _accessibilityFrontMostApplication] bundleIdentifier];
	isBlacklistedAppInFront = blackListedApps && currentApp && [blackListedApps containsObject: currentApp];
	[networkSpeedObject hideIfNeeded];
}

%end

%hook _UIStatusBar // update colors based on status bar colors

- (void)setStyle: (long long)style
{
	%orig;

	if(networkSpeedObject) 
		[networkSpeedObject updateTextColor: (style == 1) ? [UIColor whiteColor] : [UIColor blackColor]];
}

- (void)setStyle: (long long)style forPartWithIdentifier: (id)arg2
{
	%orig;

	if(networkSpeedObject) 
		[networkSpeedObject updateTextColor: (style == 1) ? [UIColor whiteColor] : [UIColor blackColor]];
}

%end

%hook SBMainDisplaySceneLayoutStatusBarView // hide on full screen

- (void)_applyStatusBarHidden: (BOOL)arg1 withAnimation: (long long)arg2 toSceneWithIdentifier: (id)arg3
{
	isStatusBarHidden = arg1;
	[networkSpeedObject hideIfNeeded];
	%orig;
}

%end

%hook _UIStatusBarForegroundView // support for peep tweak

- (void)setHidden: (BOOL)arg
{
	%orig;

	isPeepStatusBarHidden = arg;
	[networkSpeedObject hideIfNeeded];
}

%end

%hook SBMainSwitcherViewController // check if app switcher is open

-(void)updateWindowVisibilityForSwitcherContentController: (id)arg1
{
	%orig;
	isAppSwitcherOpen = [self isMainSwitcherVisible];
}

%end

%hook SBFloatyFolderController // check if a folder is open

- (void)viewWillAppear: (BOOL)arg1
{
	%orig;
	isFolderOpen = YES;
}

- (void)viewWillDisappear: (BOOL)arg1
{
	%orig;
	isFolderOpen = NO;
}

%end

static void settingsChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
	if(backgroundColorEnabled && customBackgroundColorEnabled || customTextColorEnabled)
	{
		NSDictionary *preferencesDictionary = [NSDictionary dictionaryWithContentsOfFile: @"/var/mobile/Library/Preferences/com.johnzaro.networkspeed13prefs.colors.plist"];
		customBackgroundColor = [SparkColourPickerUtils colourWithString: [preferencesDictionary objectForKey: @"customBackgroundColor"] withFallback: @"#000000:0.50"];
		customTextColor = [SparkColourPickerUtils colourWithString: [preferencesDictionary objectForKey: @"customTextColor"] withFallback: @"#FF9400"];
	}

	if(enableDoubleTap)
	{
		NSArray *doubleTapApp = [SparkAppList getAppListForIdentifier: @"com.johnzaro.networkspeed13prefs.gestureApps" andKey: @"doubleTapApp"];
		if(doubleTapApp && [doubleTapApp count] == 1)
			doubleTapIdentifier = doubleTapApp[0];
	}

	if(enableHold)
	{
		NSArray *holdApp = [SparkAppList getAppListForIdentifier: @"com.johnzaro.networkspeed13prefs.gestureApps" andKey: @"holdApp"];
		if(holdApp && [holdApp count] == 1)
			holdIdentifier = holdApp[0];
	}

	if(enableBlackListedApps)
		blackListedApps = [SparkAppList getAppListForIdentifier: @"com.johnzaro.networkspeed13prefs.blackListedApps" andKey: @"blackListedApps"];
	else
		blackListedApps = nil;

	if(networkSpeedObject)
	{
		[networkSpeedObject updateFrame];
		[networkSpeedObject updateText];
	}
}

%ctor
{
	@autoreleasepool
	{
		pref = [[HBPreferences alloc] initWithIdentifier: @"com.johnzaro.networkspeed13prefs"];
		[pref registerBool: &enabled default: NO forKey: @"enabled"];
		if(enabled)
		{
			[pref registerBool: &showOnLockScreen default: NO forKey: @"showOnLockScreen"];
			[pref registerBool: &showOnlyOnLockScreen default: NO forKey: @"showOnlyOnLockScreen"];
			[pref registerBool: &showOnControlCenter default: NO forKey: @"showOnControlCenter"];
			[pref registerBool: &hideOnFullScreen default: NO forKey: @"hideOnFullScreen"];
			[pref registerBool: &hideOnLandscape default: NO forKey: @"hideOnLandscape"];
			[pref registerBool: &showAlways default: NO forKey: @"showAlways"];
			[pref registerBool: &hideOnAppSwitcherFolder default: NO forKey: @"hideOnAppSwitcherFolder"];
			[pref registerBool: &notchlessSupport default: NO forKey: @"notchlessSupport"];
			[pref registerInteger: &separateSpeeds default: 0 forKey: @"separateSpeeds"];
			[pref registerBool: &showDownloadSpeedFirst default: NO forKey: @"showDownloadSpeedFirst"];
			[pref registerBool: &showSecondSpeedInNewLine default: NO forKey: @"showSecondSpeedInNewLine"];
			[pref registerBool: &showUploadSpeed default: NO forKey: @"showUploadSpeed"];
			[pref registerObject: &uploadPrefix default: @"↑" forKey: @"uploadPrefix"];
			[pref registerBool: &showDownloadSpeed default: NO forKey: @"showDownloadSpeed"];
			[pref registerObject: &downloadPrefix default: @"↓" forKey: @"downloadPrefix"];
			[pref registerObject: &separator default: @" " forKey: @"separator"];
			[pref registerInteger: &dataUnit default: 0 forKey: @"dataUnit"];
			[pref registerInteger: &minimumUnit default: 0 forKey: @"minimumUnit"];
			[pref registerBool: &backgroundColorEnabled default: NO forKey: @"backgroundColorEnabled"];
			[pref registerInteger: &margin default: 3 forKey: @"margin"];
			[pref registerFloat: &backgroundCornerRadius default: 6 forKey: @"backgroundCornerRadius"];
			[pref registerBool: &customBackgroundColorEnabled default: NO forKey: @"customBackgroundColorEnabled"];
			[pref registerFloat: &portraitX default: 280 forKey: @"portraitX"];
			[pref registerFloat: &portraitY default: 32 forKey: @"portraitY"];
			[pref registerFloat: &landscapeX default: 735 forKey: @"landscapeX"];
			[pref registerFloat: &landscapeY default: 32 forKey: @"landscapeY"];
			[pref registerBool: &followDeviceOrientation default: NO forKey: @"followDeviceOrientation"];
			[pref registerBool: &animateMovement default: NO forKey: @"animateMovement"];
			[pref registerFloat: &width default: 95 forKey: @"width"];
			[pref registerFloat: &height default: 12 forKey: @"height"];
			[pref registerInteger: &fontSize default: 8 forKey: @"fontSize"];
			[pref registerBool: &boldFont default: NO forKey: @"boldFont"];
			[pref registerBool: &customTextColorEnabled default: NO forKey: @"customTextColorEnabled"];
			[pref registerInteger: &alignment default: 1 forKey: @"alignment"];
			[pref registerDouble: &updateInterval default: 1 forKey: @"updateInterval"];
			[pref registerBool: &enableDoubleTap default: NO forKey: @"enableDoubleTap"];
			[pref registerBool: &enableHold default: NO forKey: @"enableHold"];
			[pref registerBool: &enableBlackListedApps default: NO forKey: @"enableBlackListedApps"];

			settingsChanged(NULL, NULL, NULL, NULL, NULL);
			CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, settingsChanged, CFSTR("com.johnzaro.networkspeed13prefs/ReloadPrefs"), NULL, CFNotificationSuspensionBehaviorCoalesce);
			%init;
		}
	}
}