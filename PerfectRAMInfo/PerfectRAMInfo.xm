#import "PerfectRAMInfo.h"

#import "SparkColourPickerUtils.h"
#import "SparkAppList.h"
#import <Cephei/HBPreferences.h>
#import <mach/mach_init.h>
#import <mach/mach_host.h>

#define DegreesToRadians(degrees) (degrees * M_PI / 180)

static const unsigned int MEGABYTES = 1 << 20;
static unsigned long long PHYSICAL_MEMORY;

__strong static id ramInfoObject;

static HBPreferences *pref;
static BOOL enabled;
static BOOL showOnLockScreen;
static BOOL showOnlyOnLockScreen;
static BOOL showOnControlCenter;
static BOOL hideOnFullScreen;
static BOOL hideOnLandscape;
static BOOL hideOnAppSwitcherFolder;
static BOOL notchlessSupport;
static BOOL showUsedRam;
static NSString *usedRAMPrefix;
static BOOL showFreeRam;
static NSString *freeRAMPrefix;
static BOOL showTotalPhysicalRam;
static NSString *totalRAMPrefix;
static NSString *separator;
static BOOL backgroundColorEnabled;
static NSInteger margin;
static CGFloat backgroundCornerRadius;
static BOOL customBackgroundColorEnabled;
static UIColor *customBackgroundColor;
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

static NSString* getMemoryStats()
{
	mach_port_t host_port;
	mach_msg_type_number_t host_size;
	vm_size_t pagesize;
	vm_statistics_data_t vm_stat;
	natural_t mem_used, mem_free;
	NSMutableString* mutableString = [[NSMutableString alloc] init];

	host_port = mach_host_self();
	host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
	host_page_size(host_port, &pagesize);
	if(host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) == KERN_SUCCESS)
	{
		if(showUsedRam)
		{
			mem_used = (vm_stat.active_count + vm_stat.inactive_count + vm_stat.wire_count) * pagesize / MEGABYTES;
			[mutableString appendString: [NSString stringWithFormat:@"%@%uMB", usedRAMPrefix, mem_used]];
		}
		if(showFreeRam)
		{
			mem_free = vm_stat.free_count * pagesize / MEGABYTES;
			if([mutableString length] != 0) [mutableString appendString: separator];
			[mutableString appendString: [NSString stringWithFormat:@"%@%uMB", freeRAMPrefix, mem_free]];
		}
		if(showTotalPhysicalRam)
		{
			if([mutableString length] != 0) [mutableString appendString: separator];
			[mutableString appendString: [NSString stringWithFormat:@"%@%lluMB", totalRAMPrefix, PHYSICAL_MEMORY]];
		}
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
	
	if((followDeviceOrientation || hideOnLandscape) && ramInfoObject) 
		[ramInfoObject updateOrientation];
}

static void loadDeviceScreenDimensions()
{
	screenWidth = [[UIScreen mainScreen] _referenceBounds].size.width;
	screenHeight = [[UIScreen mainScreen] _referenceBounds].size.height;
}

@implementation RamInfo

	- (id)init
	{
		self = [super init];
		if(self)
		{
			ramInfoLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, 0, 0)];
			[ramInfoLabel setAdjustsFontSizeToFitWidth: YES];

			UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(openDoubleTapApp)];
			[tapGestureRecognizer setNumberOfTapsRequired: 2];

			UILongPressGestureRecognizer *holdGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget: self action: @selector(openHoldApp)];
			
			ramInfoWindow = [[UIWindow alloc] initWithFrame: CGRectMake(0, 0, 0, 0)];
			[ramInfoWindow _setSecure: YES];
			[[ramInfoWindow layer] setAnchorPoint: CGPointZero];
			[ramInfoWindow addSubview: ramInfoLabel];
			[ramInfoWindow addGestureRecognizer: tapGestureRecognizer];
			[ramInfoWindow addGestureRecognizer: holdGestureRecognizer];
			
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
			[ramInfoWindow setWindowLevel: 100000];
		else
			[ramInfoWindow setWindowLevel: 1075];

		if(!backgroundColorEnabled)
			[ramInfoWindow setBackgroundColor: [UIColor clearColor]];
		else
		{
			if(customBackgroundColorEnabled)
				[ramInfoWindow setBackgroundColor: customBackgroundColor];
			else
				[ramInfoWindow setBackgroundColor: backupBackgroundColor];

			[[ramInfoWindow layer] setCornerRadius: backgroundCornerRadius];
		}

		[self updatePerfectRAMInfoLabelProperties];
		[self updatePerfectRAMInfoLabelSize];
		[self updateOrientation];
	}

	- (void)updatePerfectRAMInfoLabelProperties
	{
		if(boldFont) [ramInfoLabel setFont: [UIFont boldSystemFontOfSize: fontSize]];
		else [ramInfoLabel setFont: [UIFont systemFontOfSize: fontSize]];

		[ramInfoLabel setTextAlignment: alignment];

		if(customTextColorEnabled)
			[ramInfoLabel setTextColor: customTextColor];
		else
			[ramInfoLabel setTextColor: backupForegroundColor];
	}

	- (void)updatePerfectRAMInfoLabelSize
	{
		CGRect frame = [ramInfoLabel frame];
		frame.origin.x = margin;
		frame.origin.y = margin;
		frame.size.width = width - 2 * margin;
		frame.size.height = height - 2 * margin;
		[ramInfoLabel setFrame: frame];
	}

	- (void)updateOrientation
	{
		shouldHideBasedOnOrientation = hideOnLandscape && isOnLandscape;
		[self hideIfNeeded];

		if(deviceOrientation == orientationOld)
			return;

		CGAffineTransform newTransform;
		CGRect frame = [ramInfoWindow frame];

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
				[ramInfoWindow setTransform: newTransform];
				[ramInfoWindow setFrame: frame];
				orientationOld = deviceOrientation;
			} completion: nil];
		}
		else
		{
			[ramInfoWindow setTransform: newTransform];
			[ramInfoWindow setFrame: frame];
			orientationOld = deviceOrientation;
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
				[ramInfoLabel setTextColor: color];

			if(backgroundColorEnabled && !customBackgroundColorEnabled) 
			{
				if(r == 0)
					[ramInfoWindow setBackgroundColor: [[UIColor whiteColor] colorWithAlphaComponent: 0.5]];
				else
					[ramInfoWindow setBackgroundColor: [[UIColor blackColor] colorWithAlphaComponent: 0.5]];
				backupBackgroundColor = [ramInfoWindow backgroundColor];
			}
		}
	}

	- (void)updateText
	{
		if(ramInfoWindow && ramInfoLabel)
		{
			[self hideIfNeeded];
			if(![ramInfoWindow isHidden])
				[ramInfoLabel setText: getMemoryStats()];
		}
	}

	- (void)hideIfNeeded
	{
		[ramInfoWindow setHidden: 
			[coverSheetPresentationManagerInstance _isEffectivelyLocked] 
		 || [coverSheetPresentationManagerInstance isPresented] && !showOnLockScreen
		 || ![coverSheetPresentationManagerInstance isPresented] && showOnlyOnLockScreen
		 || isStatusBarHidden && hideOnFullScreen
		 || [controlCenterControllerInstance isVisible] && !showOnControlCenter
		 || (isFolderOpen || isAppSwitcherOpen) && hideOnAppSwitcherFolder
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

%hook SpringBoard

- (void)applicationDidFinishLaunching: (id)application // load module
{
	%orig;

	loadDeviceScreenDimensions();
	if(!ramInfoObject) 
		ramInfoObject = [[RamInfo alloc] init];
}

- (void)frontDisplayDidChange: (id)arg1 // check if opened app is blacklisted
{
	%orig;

	NSString *currentApp = [(SBApplication*)[self _accessibilityFrontMostApplication] bundleIdentifier];
	isBlacklistedAppInFront = blackListedApps && currentApp && [blackListedApps containsObject: currentApp];
	[ramInfoObject hideIfNeeded];
}

%end

%hook _UIStatusBar // update colors based on status bar colors

- (void)setStyle: (long long)style
{
	%orig;

	if(ramInfoObject) 
		[ramInfoObject updateTextColor: (style == 1) ? [UIColor whiteColor] : [UIColor blackColor]];
}

- (void)setStyle: (long long)style forPartWithIdentifier: (id)arg2
{
	%orig;

	if(ramInfoObject) 
		[ramInfoObject updateTextColor: (style == 1) ? [UIColor whiteColor] : [UIColor blackColor]];
}

%end

%hook SBMainDisplaySceneLayoutStatusBarView // hide on full screen

- (void)_applyStatusBarHidden: (BOOL)arg1 withAnimation: (long long)arg2 toSceneWithIdentifier: (id)arg3
{
	isStatusBarHidden = arg1;
	[ramInfoObject hideIfNeeded];
	%orig;
}

%end

%hook _UIStatusBarForegroundView // support for peep tweak

- (void)setHidden: (BOOL)arg
{
	%orig;

	isPeepStatusBarHidden = arg;
	[ramInfoObject hideIfNeeded];
}

%end

%hook SBMainSwitcherViewController // check if app switcher is open

-(void)updateWindowVisibilityForSwitcherContentController: (id)arg1
{
	%orig;

	isAppSwitcherOpen = [self isMainSwitcherVisible];
	[ramInfoObject hideIfNeeded];
}

%end

%hook SBFloatyFolderController // check if a folder is open

- (void)viewWillAppear: (BOOL)arg1
{
	%orig;

	isFolderOpen = YES;
	[ramInfoObject hideIfNeeded];
}

- (void)viewWillDisappear: (BOOL)arg1
{
	%orig;

	isFolderOpen = NO;
	[ramInfoObject hideIfNeeded];
}

%end

static void settingsChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
	if(backgroundColorEnabled && customBackgroundColorEnabled || customTextColorEnabled)
	{
		NSDictionary *preferencesDictionary = [NSDictionary dictionaryWithContentsOfFile: @"/var/mobile/Library/Preferences/com.johnzaro.raminfo13prefs.colors.plist"];
		customBackgroundColor = [SparkColourPickerUtils colourWithString: [preferencesDictionary objectForKey: @"customBackgroundColor"] withFallback: @"#000000:0.50"];
		customTextColor = [SparkColourPickerUtils colourWithString: [preferencesDictionary objectForKey: @"customTextColor"] withFallback: @"#FF9400"];
	}

	if(enableDoubleTap)
	{
		NSArray *doubleTapApp = [SparkAppList getAppListForIdentifier: @"com.johnzaro.raminfo13prefs.gestureApps" andKey: @"doubleTapApp"];
		if(doubleTapApp && [doubleTapApp count] == 1)
			doubleTapIdentifier = doubleTapApp[0];
	}

	if(enableHold)
	{
		NSArray *holdApp = [SparkAppList getAppListForIdentifier: @"com.johnzaro.raminfo13prefs.gestureApps" andKey: @"holdApp"];
		if(holdApp && [holdApp count] == 1)
			holdIdentifier = holdApp[0];
	}

	if(enableBlackListedApps)
		blackListedApps = [SparkAppList getAppListForIdentifier: @"com.johnzaro.raminfo13prefs.blackListedApps" andKey: @"blackListedApps"];
	else
		blackListedApps = nil;

	if(ramInfoObject) 
	{
		[ramInfoObject updateFrame];
		[ramInfoObject updateText];
	}	
}

%ctor
{
	@autoreleasepool
	{
		pref = [[HBPreferences alloc] initWithIdentifier: @"com.johnzaro.raminfo13prefs"];
		[pref registerBool: &enabled default: NO forKey: @"enabled"];
		if(enabled)
		{
			PHYSICAL_MEMORY = [NSProcessInfo processInfo].physicalMemory / MEGABYTES;

			[pref registerBool: &showOnLockScreen default: NO forKey: @"showOnLockScreen"];
			[pref registerBool: &showOnlyOnLockScreen default: NO forKey: @"showOnlyOnLockScreen"];
			[pref registerBool: &showOnControlCenter default: NO forKey: @"showOnControlCenter"];
			[pref registerBool: &hideOnFullScreen default: NO forKey: @"hideOnFullScreen"];
			[pref registerBool: &hideOnLandscape default: NO forKey: @"hideOnLandscape"];
			[pref registerBool: &hideOnAppSwitcherFolder default: NO forKey: @"hideOnAppSwitcherFolder"];
			[pref registerBool: &notchlessSupport default: NO forKey: @"notchlessSupport"];
			[pref registerBool: &showUsedRam default: NO forKey: @"showUsedRam"];
			[pref registerObject: &usedRAMPrefix default: @"U: " forKey: @"usedRAMPrefix"];
			[pref registerBool: &showFreeRam default: NO forKey: @"showFreeRam"];
			[pref registerObject: &freeRAMPrefix default: @"F: " forKey: @"freeRAMPrefix"];
			[pref registerBool: &showTotalPhysicalRam default: NO forKey: @"showTotalPhysicalRam"];
			[pref registerObject: &totalRAMPrefix default: @"T: " forKey: @"totalRAMPrefix"];
			[pref registerObject: &separator default: @", " forKey: @"separator"];
			[pref registerBool: &backgroundColorEnabled default: NO forKey: @"backgroundColorEnabled"];
			[pref registerInteger: &margin default: 3 forKey: @"margin"];
			[pref registerFloat: &backgroundCornerRadius default: 6 forKey: @"backgroundCornerRadius"];
			[pref registerBool: &customBackgroundColorEnabled default: NO forKey: @"customBackgroundColorEnabled"];
			[pref registerFloat: &portraitX default: 298 forKey: @"portraitX"];
			[pref registerFloat: &portraitY default: 2 forKey: @"portraitY"];
			[pref registerFloat: &landscapeX default: 750 forKey: @"landscapeX"];
			[pref registerFloat: &landscapeY default: 2 forKey: @"landscapeY"];
			[pref registerBool: &followDeviceOrientation default: NO forKey: @"followDeviceOrientation"];
			[pref registerBool: &animateMovement default: NO forKey: @"animateMovement"];
			[pref registerFloat: &width default: 55 forKey: @"width"];
			[pref registerFloat: &height default: 12 forKey: @"height"];
			[pref registerInteger: &fontSize default: 8 forKey: @"fontSize"];
			[pref registerBool: &boldFont default: NO forKey: @"boldFont"];
			[pref registerBool: &customTextColorEnabled default: NO forKey: @"customTextColorEnabled"];
			[pref registerInteger: &alignment default: 0 forKey: @"alignment"];
			[pref registerDouble: &updateInterval default: 2 forKey: @"updateInterval"];
			[pref registerBool: &enableDoubleTap default: NO forKey: @"enableDoubleTap"];
			[pref registerBool: &enableHold default: NO forKey: @"enableHold"];
			[pref registerBool: &enableBlackListedApps default: NO forKey: @"enableBlackListedApps"];

			settingsChanged(NULL, NULL, NULL, NULL, NULL);
			CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, settingsChanged, CFSTR("com.johnzaro.raminfo13prefs/ReloadPrefs"), NULL, CFNotificationSuspensionBehaviorCoalesce);
			%init;
		}
	}
}