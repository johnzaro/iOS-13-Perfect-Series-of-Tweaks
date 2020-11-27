#import "PerfectBTBatteryInfo.h"
#import "SparkAppList.h"
#import "SparkColourPickerUtils.h"
#import <Cephei/HBPreferences.h>

#define DegreesToRadians(degrees) (degrees * M_PI / 180)

__strong static id bluetoothBatteryInfoObject;

static double windowWidth;
static double windowHeight;
static double labelsHeight;

static HBPreferences *pref;
static BOOL enabled;
static BOOL showOnLockScreen;
static BOOL showOnlyOnLockScreen;
static BOOL showOnControlCenter;
static BOOL hideOnFullScreen;
static BOOL hideOnLandscape;
static BOOL hideOnAppSwitcherFolder;
static BOOL notchlessSupport;
static BOOL hideInternalBattery;
static BOOL hideGlyph;
static BOOL dynamicHeadphonesIcon;
static BOOL hideBluetoothDevicesBatteryFromStatusBar;
static BOOL hideDeviceNameLabel;
static BOOL showPercentSymbol;
static long glyphSize;
static BOOL enableGlyphCustomTintColor;
static UIColor *glyphCustomTintColor;
static long percentageFontSize;
static BOOL percentageFontBold;
static long nameFontSize;
static BOOL nameFontBold;
static BOOL backgroundColorEnabled;
static NSInteger margin;
static CGFloat backgroundCornerRadius;
static BOOL customBackgroundColorEnabled;
static UIColor *customBackgroundColor;
static BOOL enableCustomDeviceNameColor;
static UIColor *customDeviceNameColor;
static double portraitX;
static double portraitY;
static double landscapeX;
static double landscapeY;
static BOOL followDeviceOrientation;
static BOOL animateMovement;
static BOOL enableBlackListedApps;
static NSArray *blackListedApps;
static BOOL defaultColorEnabled;
static BOOL chargingColorEnabled;
static BOOL lowPowerModeColorEnabled;
static BOOL lowBattery1ColorEnabled;
static BOOL lowBattery2ColorEnabled;
static UIColor *customDefaultColor;
static UIColor *chargingColor;
static UIColor *lowPowerModeColor;
static UIColor *lowBattery1Color;
static UIColor *lowBattery2Color;

static double screenWidth;
static double screenHeight;
static UIDeviceOrientation orientationOld;
static UIDeviceOrientation deviceOrientation;
static BOOL isBlacklistedAppInFront = NO;
static BOOL shouldHideBasedOnOrientation = NO;
static BOOL isLockScreenPresented = YES;
static BOOL isControlCenterVisible = NO;
static BOOL noDevicesAvailable = NO;
static BOOL isOnLandscape;
static unsigned int deviceIndex;
static NSString *percentSymbol;
static BOOL useSystemColorForPercentage = YES;
static BOOL isPeepStatusBarHidden = NO;
static BOOL isStatusBarHidden = NO;
static BOOL isAppSwitcherOpen = NO;
static BOOL isFolderOpen = NO;

static void orientationChanged()
{
	deviceOrientation = [[UIApplication sharedApplication] _frontMostAppOrientation];
	if(deviceOrientation == UIDeviceOrientationLandscapeRight || deviceOrientation == UIDeviceOrientationLandscapeLeft)
		isOnLandscape = YES;
	else
		isOnLandscape = NO;

	if((hideOnLandscape || followDeviceOrientation) && bluetoothBatteryInfoObject) 
		[bluetoothBatteryInfoObject updateWindowFrameWithAnimation: YES];
}

static void loadDeviceScreenDimensions()
{
	screenWidth = [[UIScreen mainScreen] _referenceBounds].size.width;
	screenHeight = [[UIScreen mainScreen] _referenceBounds].size.height;
}

@implementation PerfectBTBatteryInfo

	- (id)init
	{
		self = [super init];
		if(self)
		{
			glyphImageView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, 0, 0)];
			[glyphImageView setContentMode: UIViewContentModeScaleAspectFit];
			
			percentageLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, 0, 0)];
			deviceNameLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, 0, 0)];
			
			bluetoothBatteryInfoWindow = [[UIWindow alloc] initWithFrame: CGRectMake(0, 0, 0, 0)];
			[bluetoothBatteryInfoWindow _setSecure: YES];
			[[bluetoothBatteryInfoWindow layer] setAnchorPoint: CGPointZero];
			[bluetoothBatteryInfoWindow addSubview: glyphImageView];
			[bluetoothBatteryInfoWindow addSubview: percentageLabel];
			[bluetoothBatteryInfoWindow addSubview: deviceNameLabel];
			[bluetoothBatteryInfoWindow addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(updateDeviceWithEffects)]];

			deviceIndex = 0;
			backupForegroundColor = [UIColor whiteColor];
			backupBackgroundColor = [[UIColor blackColor] colorWithAlphaComponent: 0.5];

			[self updateObjectWithNewSettings];

			[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(updateDeviceWithoutEffects) name: @"BCBatteryDeviceControllerConnectedDevicesDidChange" object: nil];
			CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)&orientationChanged, CFSTR("com.apple.springboard.screenchanged"), NULL, 0);
			CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(), NULL, (CFNotificationCallback)&orientationChanged, CFSTR("UIWindowDidRotateNotification"), NULL, CFNotificationSuspensionBehaviorCoalesce);
		}
		return self;
	}

	- (void)updateObjectWithNewSettings
	{
		[NSObject cancelPreviousPerformRequestsWithTarget: self selector: @selector(_updateObjectWithNewSettings) object: nil];
		[self performSelector: @selector(_updateObjectWithNewSettings) withObject: nil afterDelay: 0.3];
	}

	- (void)_updateObjectWithNewSettings
	{
		orientationOld = nil;

		if(notchlessSupport)
			[bluetoothBatteryInfoWindow setWindowLevel: 100000];
		else
			[bluetoothBatteryInfoWindow setWindowLevel: 1075];
		
		if(!backgroundColorEnabled)
			[bluetoothBatteryInfoWindow setBackgroundColor: [UIColor clearColor]];
		else
		{
			if(customBackgroundColorEnabled)
				[bluetoothBatteryInfoWindow setBackgroundColor: customBackgroundColor];
			else
				[bluetoothBatteryInfoWindow setBackgroundColor: backupBackgroundColor];

			[[bluetoothBatteryInfoWindow layer] setCornerRadius: backgroundCornerRadius];
		}

		if(enableGlyphCustomTintColor)
			[glyphImageView setTintColor: glyphCustomTintColor];
		else
			[glyphImageView setTintColor: backupForegroundColor];

		if(enableCustomDeviceNameColor)
			[deviceNameLabel setTextColor: customDeviceNameColor];
		else
			[deviceNameLabel setTextColor: backupForegroundColor];
		
		[self updateLabelsFont];

		[self calculateNewWindowSize];

		[self updateGlyphFrame];
		[self updateLabelsFrame];
		[self updateWindowFrameWithAnimation: NO];
	}

	- (void)calculateNewWindowSize
	{
		windowWidth = (hideGlyph ? 0 : glyphSize) + 3 + MAX([percentageLabel frame].size.width, (hideDeviceNameLabel ? 0 : [deviceNameLabel frame].size.width)) + 2 * margin;
		windowHeight = MAX((hideGlyph ? 0 : glyphSize), labelsHeight) + 2 * margin;
	}

	- (void)updateLabelsFont
	{
		if(percentageFontBold) [percentageLabel setFont: [UIFont boldSystemFontOfSize: percentageFontSize]];
		else [percentageLabel setFont: [UIFont systemFontOfSize: percentageFontSize]];
		[percentageLabel sizeToFit];
		
		if(!hideDeviceNameLabel)
		{
			if(nameFontBold) [deviceNameLabel setFont: [UIFont boldSystemFontOfSize: nameFontSize]];
			else [deviceNameLabel setFont: [UIFont systemFontOfSize: nameFontSize]];
			[deviceNameLabel sizeToFit];
		}

		labelsHeight = (percentageFontSize + (hideDeviceNameLabel ? 0 : nameFontSize)) * 1.217;
	}

	- (void)updateGlyphFrame
	{
		if(hideGlyph)
			[glyphImageView setHidden: YES];
		else
		{
			[glyphImageView setHidden: NO];
			
			CGRect frame = [glyphImageView frame];
			frame.origin.x = margin;
			frame.origin.y = windowHeight / 2 - glyphSize / 2;
			frame.size.width = glyphSize;
			frame.size.height = glyphSize;
			[glyphImageView setFrame: frame];
		}
	}

	- (void)updateLabelsFrame
	{
		CGRect frame = [percentageLabel frame];
		frame.origin.x = margin + (hideGlyph ? 0 : glyphSize + 3);
		frame.origin.y = windowHeight / 2 - labelsHeight / 2;
		[percentageLabel setFrame: frame];

		if(hideDeviceNameLabel)
			[deviceNameLabel setHidden: YES];
		else
		{
			[deviceNameLabel setHidden: NO];

			frame = [deviceNameLabel frame];
			frame.origin.x = margin + (hideGlyph ? 0 : glyphSize + 3);
			frame.origin.y = windowHeight / 2 - labelsHeight / 2 + percentageFontSize * 1.217;
			[deviceNameLabel setFrame: frame];
		}
	}

	- (void)updateWindowFrameWithAnimation: (BOOL)animate
	{
		shouldHideBasedOnOrientation = hideOnLandscape && isOnLandscape;
		[self hideIfNeeded];

		CGAffineTransform newTransform;
		CGRect frame = [bluetoothBatteryInfoWindow frame];

		if(!followDeviceOrientation || deviceOrientation == UIDeviceOrientationPortrait)
		{
			frame.origin.x = portraitX;
			frame.origin.y = portraitY;
			if(deviceOrientation != orientationOld)
				newTransform = CGAffineTransformMakeRotation(DegreesToRadians(0));
		}
		else if(deviceOrientation == UIDeviceOrientationLandscapeLeft)
		{
			frame.origin.x = screenWidth - landscapeY;
			frame.origin.y = landscapeX;
			if(deviceOrientation != orientationOld)
				newTransform = CGAffineTransformMakeRotation(DegreesToRadians(90));
		}
		else if(deviceOrientation == UIDeviceOrientationPortraitUpsideDown)
		{
			frame.origin.x = screenWidth - portraitX;
			frame.origin.y = screenHeight - portraitY;
			if(deviceOrientation != orientationOld)
				newTransform = CGAffineTransformMakeRotation(DegreesToRadians(180));
		}
		else if(deviceOrientation == UIDeviceOrientationLandscapeRight)
		{
			frame.origin.x = landscapeY;
			frame.origin.y = screenHeight - landscapeX;
			if(deviceOrientation != orientationOld)
				newTransform = CGAffineTransformMakeRotation(-DegreesToRadians(90));
		}

		frame.size.width = isOnLandscape && followDeviceOrientation ? windowHeight : windowWidth;
		frame.size.height = isOnLandscape && followDeviceOrientation ? windowWidth : windowHeight;

		if(animate && animateMovement)
		{
			[UIView animateWithDuration: 0.3f animations:
			^{
				if(deviceOrientation != orientationOld)
					[bluetoothBatteryInfoWindow setTransform: newTransform];
				[bluetoothBatteryInfoWindow setFrame: frame];
				orientationOld = deviceOrientation;
			} completion: nil];
		}
		else
		{
			if(deviceOrientation != orientationOld)
				[bluetoothBatteryInfoWindow setTransform: newTransform];
			[bluetoothBatteryInfoWindow setFrame: frame];
			orientationOld = deviceOrientation;
		}
	}

	- (void)updatePercentageColor
	{
		if(deviceIndex <= [[[%c(BCBatteryDeviceController) sharedInstance] connectedDevices] count] && currentDevice)
		{
			useSystemColorForPercentage = NO;
			if([currentDevice isCharging] && chargingColorEnabled)
				[percentageLabel setTextColor: chargingColor];
			else if([currentDevice isBatterySaverModeActive] && lowPowerModeColorEnabled)
				[percentageLabel setTextColor: lowPowerModeColor];
			else if([currentDevice percentCharge] <= 15 && lowBattery2ColorEnabled)
				[percentageLabel setTextColor: lowBattery2Color];
			else if([currentDevice percentCharge] <= 25 && lowBattery1ColorEnabled)
				[percentageLabel setTextColor: lowBattery1Color];
			else if(defaultColorEnabled)
				[percentageLabel setTextColor: customDefaultColor];
			else 
			{
				useSystemColorForPercentage = YES;
				[percentageLabel setTextColor: backupForegroundColor];
			}
		}
	}

	- (void)updatePercentage
	{
		if(deviceIndex <= [[[%c(BCBatteryDeviceController) sharedInstance] connectedDevices] count] && currentDevice)
		{
			[percentageLabel setText: [NSString stringWithFormat: @"%lld%@", [currentDevice percentCharge], percentSymbol]];
			[percentageLabel sizeToFit];
			[self updatePercentageColor];

			[self calculateNewWindowSize];
			[self updateWindowFrameWithAnimation: NO];
		}
	}

	- (void)updateDeviceWithEffects
	{
		NSArray *devices = [[%c(BCBatteryDeviceController) sharedInstance] connectedDevices];

		deviceIndex++;
		if(deviceIndex > [devices count] - 1) deviceIndex = hideInternalBattery ? 1 : 0;
		
		if(deviceIndex > [devices count] - 1) noDevicesAvailable = YES;
		else
		{
			noDevicesAvailable = NO;

			currentDevice = devices[deviceIndex];

			if(currentDeviceIdentifier && [[currentDevice identifier] isEqualToString: currentDeviceIdentifier])
			{
				UINotificationFeedbackGenerator *gen = [[UINotificationFeedbackGenerator alloc] init];
				[gen prepare];

				CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath: @"position"];
				[animation setDuration: 0.08];
				[animation setRepeatCount: 3];
				[animation setAutoreverses: YES];
				if(deviceOrientation == UIDeviceOrientationPortrait || deviceOrientation == UIDeviceOrientationPortraitUpsideDown || !followDeviceOrientation)
				{
					[animation setFromValue: [NSValue valueWithCGPoint: CGPointMake([bluetoothBatteryInfoWindow center].x - 4, [bluetoothBatteryInfoWindow center].y)]];
					[animation setToValue: [NSValue valueWithCGPoint: CGPointMake([bluetoothBatteryInfoWindow center].x + 4, [bluetoothBatteryInfoWindow center].y)]];
				}
				else
				{
					[animation setFromValue: [NSValue valueWithCGPoint: CGPointMake([bluetoothBatteryInfoWindow center].x, [bluetoothBatteryInfoWindow center].y - 4)]];
					[animation setToValue: [NSValue valueWithCGPoint: CGPointMake([bluetoothBatteryInfoWindow center].x, [bluetoothBatteryInfoWindow center].y + 4)]];
				}
				[[bluetoothBatteryInfoWindow layer] addAnimation: animation forKey: @"position"];

				[gen notificationOccurred: UINotificationFeedbackTypeError];
			}
			else
			{
				UIImpactFeedbackGenerator *gen = [[UIImpactFeedbackGenerator alloc] initWithStyle: UIImpactFeedbackStyleMedium];
				[gen prepare];

				[CATransaction begin];
				[CATransaction setAnimationDuration: 0.25];
				[CATransaction setAnimationTimingFunction: [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];

				[CATransaction setCompletionBlock:
				^{
					[self loadNewDeviceValues];

					CABasicAnimation *positionAnimation2 = [CABasicAnimation animationWithKeyPath: @"position"];
					if(deviceOrientation == UIDeviceOrientationPortrait || !followDeviceOrientation)
					{
						[positionAnimation2 setFromValue: [NSValue valueWithCGPoint: CGPointMake([bluetoothBatteryInfoWindow center].x + 15, [bluetoothBatteryInfoWindow center].y)]];
						[positionAnimation2 setToValue: [NSValue valueWithCGPoint: CGPointMake([bluetoothBatteryInfoWindow center].x, [bluetoothBatteryInfoWindow center].y)]];
					}
					else if(deviceOrientation == UIDeviceOrientationLandscapeLeft)
					{
						[positionAnimation2 setFromValue: [NSValue valueWithCGPoint: CGPointMake([bluetoothBatteryInfoWindow center].x, [bluetoothBatteryInfoWindow center].y + 15)]];
						[positionAnimation2 setToValue: [NSValue valueWithCGPoint: CGPointMake([bluetoothBatteryInfoWindow center].x, [bluetoothBatteryInfoWindow center].y)]];
					}
					else if(deviceOrientation == UIDeviceOrientationLandscapeRight)
					{
						[positionAnimation2 setFromValue: [NSValue valueWithCGPoint: CGPointMake([bluetoothBatteryInfoWindow center].x, [bluetoothBatteryInfoWindow center].y - 15)]];
						[positionAnimation2 setToValue: [NSValue valueWithCGPoint: CGPointMake([bluetoothBatteryInfoWindow center].x, [bluetoothBatteryInfoWindow center].y)]];
					}
					else
					{
						[positionAnimation2 setFromValue: [NSValue valueWithCGPoint: CGPointMake([bluetoothBatteryInfoWindow center].x - 15, [bluetoothBatteryInfoWindow center].y)]];
						[positionAnimation2 setToValue: [NSValue valueWithCGPoint: CGPointMake([bluetoothBatteryInfoWindow center].x, [bluetoothBatteryInfoWindow center].y)]];
					}
					[positionAnimation2 setDuration: 0.25];
					
					CABasicAnimation *opacityAnimation2 = [CABasicAnimation animationWithKeyPath: @"opacity"];
					[opacityAnimation2 setFromValue: [NSNumber numberWithFloat: 0]];
					[opacityAnimation2 setToValue: [NSNumber numberWithFloat: 1]];
					[opacityAnimation2 setDuration: 0.25];

					CAAnimationGroup *animationGroup2 = [CAAnimationGroup animation];
					[animationGroup2 setDuration: 0.25];
					[animationGroup2 setTimingFunction: [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
					[animationGroup2 setAnimations: @[positionAnimation2, opacityAnimation2]];
					[[bluetoothBatteryInfoWindow layer] addAnimation: animationGroup2 forKey: @"animationGroup2"];

					[[bluetoothBatteryInfoWindow layer] removeAnimationForKey: @"animationGroup1"];
				}];

				CABasicAnimation *positionAnimation1 = [CABasicAnimation animationWithKeyPath: @"position"];
				if(deviceOrientation == UIDeviceOrientationPortrait || !followDeviceOrientation)
				{
					[positionAnimation1 setFromValue: [NSValue valueWithCGPoint: CGPointMake([bluetoothBatteryInfoWindow center].x, [bluetoothBatteryInfoWindow center].y)]];
					[positionAnimation1 setToValue: [NSValue valueWithCGPoint: CGPointMake([bluetoothBatteryInfoWindow center].x - 15, [bluetoothBatteryInfoWindow center].y)]];
				}
				else if(deviceOrientation == UIDeviceOrientationLandscapeLeft)
				{
					[positionAnimation1 setFromValue: [NSValue valueWithCGPoint: CGPointMake([bluetoothBatteryInfoWindow center].x, [bluetoothBatteryInfoWindow center].y)]];
					[positionAnimation1 setToValue: [NSValue valueWithCGPoint: CGPointMake([bluetoothBatteryInfoWindow center].x, [bluetoothBatteryInfoWindow center].y - 15)]];
				}
				else if(deviceOrientation == UIDeviceOrientationLandscapeRight)
				{
					[positionAnimation1 setFromValue: [NSValue valueWithCGPoint: CGPointMake([bluetoothBatteryInfoWindow center].x, [bluetoothBatteryInfoWindow center].y)]];
					[positionAnimation1 setToValue: [NSValue valueWithCGPoint: CGPointMake([bluetoothBatteryInfoWindow center].x, [bluetoothBatteryInfoWindow center].y + 15)]];
				}
				else
				{
					[positionAnimation1 setFromValue: [NSValue valueWithCGPoint: CGPointMake([bluetoothBatteryInfoWindow center].x, [bluetoothBatteryInfoWindow center].y)]];
					[positionAnimation1 setToValue: [NSValue valueWithCGPoint: CGPointMake([bluetoothBatteryInfoWindow center].x + 15, [bluetoothBatteryInfoWindow center].y)]];
				}
				[positionAnimation1 setDuration: 0.25];
				
				CABasicAnimation *opacityAnimation1 = [CABasicAnimation animationWithKeyPath: @"opacity"];
				[opacityAnimation1 setFromValue: [NSNumber numberWithFloat: 1]];
				[opacityAnimation1 setToValue: [NSNumber numberWithFloat: 0]];
				[opacityAnimation1 setDuration: 0.25];

				CAAnimationGroup *animationGroup1 = [CAAnimationGroup animation];
				[animationGroup1 setDuration: 0.25];
				[animationGroup1 setTimingFunction: [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
				[animationGroup1 setAnimations: @[positionAnimation1, opacityAnimation1]];
				[animationGroup1 setFillMode: kCAFillModeForwards];
				[animationGroup1 setRemovedOnCompletion: NO];
				[[bluetoothBatteryInfoWindow layer] addAnimation: animationGroup1 forKey: @"animationGroup1"];

				[CATransaction commit];
				
				[gen impactOccurred];
			}
		}

		[self hideIfNeeded];
	}

	- (void)updateDeviceWithoutEffects
	{
		NSArray *devices = [[%c(BCBatteryDeviceController) sharedInstance] connectedDevices];
		if(hideInternalBattery && deviceIndex == 0) deviceIndex++;
		if(deviceIndex > [devices count] - 1) deviceIndex = hideInternalBattery ? 1 : 0;
		
		if(deviceIndex > [devices count] - 1) noDevicesAvailable = YES;
		else
		{
			noDevicesAvailable = NO;

			currentDevice = devices[deviceIndex];

			if(!currentDeviceIdentifier || ![[currentDevice identifier] isEqualToString: currentDeviceIdentifier])
				[self loadNewDeviceValues];
		}

		[self hideIfNeeded];
	}

	- (void)loadNewDeviceValues
	{
		currentDeviceIdentifier = [currentDevice identifier];

		if([[[[currentDevice glyph] imageAsset] assetName] containsString: @"bluetooth"])
			[glyphImageView setImage: [[UIImage imageWithContentsOfFile: @"/Library/PreferenceBundles/PerfectBTBatteryInfoPrefs.bundle/genericBluetoothIcon.png"] imageWithRenderingMode: UIImageRenderingModeAlwaysTemplate]];
		else
			[glyphImageView setImage: [[currentDevice glyph] imageWithRenderingMode: UIImageRenderingModeAlwaysTemplate]];

		[deviceNameLabel setText: [self getDeviceName: [[[currentDevice glyph] imageAsset] assetName]]];
		[deviceNameLabel sizeToFit];
		[self updatePercentage];
	}

	- (void)updateTextColor: (UIColor*)color
	{
		backupForegroundColor = color;
		CGFloat r;
    	[color getRed: &r green: nil blue: nil alpha: nil];
		if(r == 0 || r == 1)
		{
			if(backgroundColorEnabled && !customBackgroundColorEnabled) 
			{
				if(r == 0) [bluetoothBatteryInfoWindow setBackgroundColor: [[UIColor whiteColor] colorWithAlphaComponent: 0.5]];
				else [bluetoothBatteryInfoWindow setBackgroundColor: [[UIColor blackColor] colorWithAlphaComponent: 0.5]];
				backupBackgroundColor = [bluetoothBatteryInfoWindow backgroundColor];
			}

			if(!enableGlyphCustomTintColor)
				[glyphImageView setTintColor: color];

			if(!enableCustomDeviceNameColor)
				[deviceNameLabel setTextColor: color];

			if(useSystemColorForPercentage)
			{
				[[percentageLabel textColor] getRed: &r green: nil blue: nil alpha: nil];
				if(r == 0 || r == 1)
					[percentageLabel setTextColor: color];
			}
		}
	}

	- (void)hideIfNeeded
	{
		[bluetoothBatteryInfoWindow setHidden: 
			noDevicesAvailable 
		 || isLockScreenPresented && !showOnLockScreen
		 || !isLockScreenPresented && showOnlyOnLockScreen
		 || isStatusBarHidden && hideOnFullScreen
		 || isControlCenterVisible && !showOnControlCenter
		 || (isFolderOpen || isAppSwitcherOpen) && hideOnAppSwitcherFolder
		 || !isLockScreenPresented && (shouldHideBasedOnOrientation || isBlacklistedAppInFront)
		 || isPeepStatusBarHidden];
	}

	- (NSString*)getDeviceName: (NSString*)assetName
	{
		if([assetName containsString: @"case"] || [assetName containsString: @"r7x"]) return @"Case";
		else if([assetName containsString: @"iphone"]) return @"iPhone";
		else if(([assetName containsString: @"airpods"] || [assetName containsString: @"b298"]) && [assetName containsString: @"left"] && [assetName containsString: @"right"]) return @"Airpods";
		else if(([assetName containsString: @"airpods"] || [assetName containsString: @"b298"]) && [assetName containsString: @"left"]) return @"L Airpod";
		else if(([assetName containsString: @"airpods"] || [assetName containsString: @"b298"]) && [assetName containsString: @"right"]) return @"R Airpod";
		else if([assetName containsString: @"ipad"]) return @"iPad";
		else if([assetName containsString: @"watch"]) return @"Watch";
		else if([assetName containsString: @"beats"] && [assetName containsString: @"left"] && [assetName containsString: @"right"]) return @"Beats";
		else if([assetName containsString: @"beatspro"] && [assetName containsString: @"left"]) return @"L Beats";
		else if([assetName containsString: @"beatspro"] && [assetName containsString: @"right"]) return @"R Beats";
		else if([assetName containsString: @"beats"] || [assetName containsString: @"b419"] || [assetName containsString: @"b364"]) return @"Beats";
		else if([assetName containsString: @"gamecontroller"]) return @"Controller";
		else if([assetName containsString: @"pencil"]) return @"Pencil";
		else if([assetName containsString: @"ipod"]) return @"iPod";
		else if([assetName containsString: @"mouse"] || [assetName containsString: @"a125"]) return @"Mouse";
		else if([assetName containsString: @"trackpad"]) return @"Trackpad";
		else if([assetName containsString: @"keyboard"]) return @"Keyboard";
		else return @"Device";
	}

@end

%hook BCBatteryDevice // update percentage and color

- (void)setCharging: (BOOL)arg1
{
	%orig;
	dispatch_async(dispatch_get_main_queue(), ^{ [bluetoothBatteryInfoObject updatePercentageColor]; });
}

- (void)setPercentCharge: (long long)arg1
{
	%orig;
	dispatch_async(dispatch_get_main_queue(), ^{ [bluetoothBatteryInfoObject updatePercentage]; });
}

- (void)setBatterySaverModeActive: (BOOL)arg1
{
	%orig;
	dispatch_async(dispatch_get_main_queue(), ^{ [bluetoothBatteryInfoObject updatePercentageColor]; });
}

%end

%hook SpringBoard

- (void)applicationDidFinishLaunching: (id)application // load module
{
	%orig;

	loadDeviceScreenDimensions();
	if(!bluetoothBatteryInfoObject) 
	{
		bluetoothBatteryInfoObject = [[PerfectBTBatteryInfo alloc] init];
		[bluetoothBatteryInfoObject updateDeviceWithoutEffects];
	}
}

- (void)frontDisplayDidChange: (id)arg1 // check if opened app is blacklisted
{
	%orig;

	NSString *currentApp = [(SBApplication*)[self _accessibilityFrontMostApplication] bundleIdentifier];
	isBlacklistedAppInFront = blackListedApps && currentApp && [blackListedApps containsObject: currentApp];
	[bluetoothBatteryInfoObject hideIfNeeded];
}

%end

%hook SBCoverSheetPresentationManager // check if lock screen is presented or not

- (BOOL)isPresented
{
	isLockScreenPresented = %orig;
	[bluetoothBatteryInfoObject hideIfNeeded];
	return isLockScreenPresented;
}

%end

%hook SBControlCenterController // check if control center is presented or not

-(BOOL)isVisible
{
	isControlCenterVisible = %orig;
	[bluetoothBatteryInfoObject hideIfNeeded];
	return isControlCenterVisible;
}

%end

%hook _UIStatusBar // update colors based on status bar colors

- (void)setStyle: (long long)style
{
	%orig;

	if(bluetoothBatteryInfoObject) 
		[bluetoothBatteryInfoObject updateTextColor: (style == 1) ? [UIColor whiteColor] : [UIColor blackColor]];
}

- (void)setStyle: (long long)style forPartWithIdentifier: (id)arg2
{
	%orig;

	if(bluetoothBatteryInfoObject) 
		[bluetoothBatteryInfoObject updateTextColor: (style == 1) ? [UIColor whiteColor] : [UIColor blackColor]];
}

%end

%hook SBMainDisplaySceneLayoutStatusBarView // hide on full screen

- (void)_applyStatusBarHidden: (BOOL)arg1 withAnimation: (long long)arg2 toSceneWithIdentifier: (id)arg3
{
	isStatusBarHidden = arg1;
	[bluetoothBatteryInfoObject hideIfNeeded];
	%orig;
}

%end

%hook _UIStatusBarForegroundView // support for peep tweak

- (void)setHidden: (BOOL)arg
{
	%orig;

	isPeepStatusBarHidden = arg;
	[bluetoothBatteryInfoObject hideIfNeeded];
}

%end

%hook SBMainSwitcherViewController // check if app switcher is open

-(void)updateWindowVisibilityForSwitcherContentController: (id)arg1
{
	%orig;

	isAppSwitcherOpen = [self isMainSwitcherVisible];
	[bluetoothBatteryInfoObject hideIfNeeded];
}

%end

%hook SBFloatyFolderController // check if a folder is open

- (void)viewWillAppear: (BOOL)arg1
{
	%orig;

	isFolderOpen = YES;
	[bluetoothBatteryInfoObject hideIfNeeded];
}

- (void)viewWillDisappear: (BOOL)arg1
{
	%orig;

	isFolderOpen = NO;
	[bluetoothBatteryInfoObject hideIfNeeded];
}

%end

%group hideBluetoothDevicesBatteryFromStatusBarGroup

	%hook BluetoothDevice

	- (BOOL)supportsBatteryLevel
	{
		return NO;
	}

	%end
	
%end

%group dynamicHeadphonesIconGroup

	UIImage* getHeadphonesImage(UIImage *image)
	{
		NSString *glyphName = nil;
		CGSize imgsize = image.size;
		for(BCBatteryDevice *device in [[%c(BCBatteryDeviceController) sharedInstance] connectedDevices])
		{
			if([device.glyph.imageAsset.assetName containsString: @"airpods"]) glyphName = @"batteryglyphs-airpods-left-right";
			else if([device.glyph.imageAsset.assetName containsString: @"b298"]) 
			{
				glyphName = @"batteryglyphs-b298-left-right";
				imgsize = CGSizeMake(imgsize.width * 0.70, imgsize.height);
			}
			else if([device.glyph.imageAsset.assetName containsString: @"b364"]) 
			{
				glyphName = @"batteryglyphs-b364";
				imgsize = CGSizeMake(imgsize.width * 0.65, imgsize.height);
			}
			else if([device.glyph.imageAsset.assetName containsString: @"b419"])
			{
				glyphName = @"batteryglyphs-b419";
				imgsize = CGSizeMake(imgsize.width * 0.88, imgsize.height);

			} 
			else if([device.glyph.imageAsset.assetName containsString: @"beatssolo"])
			{
				glyphName = @"batteryglyphs-beatssolo";
				imgsize = CGSizeMake(imgsize.width * 0.92, imgsize.height);

			} 
			else if([device.glyph.imageAsset.assetName containsString: @"beatsstudio"]) 
			{
				glyphName = @"batteryglyphs-beatsstudio";
				imgsize = CGSizeMake(imgsize.width * 0.92, imgsize.height);
			}
			else if([device.glyph.imageAsset.assetName containsString: @"beatsx"]) 
			{
				glyphName = @"batteryglyphs-beatsx";
				imgsize = CGSizeMake(imgsize.width, imgsize.height * 0.92);
			}
			else if([device.glyph.imageAsset.assetName containsString: @"powerbeatspro"]) 
			{
				glyphName = @"batteryglyphs-powerbeatspro-left-right";
				imgsize = CGSizeMake(imgsize.width, imgsize.height * 0.75);
			}
			else if([device.glyph.imageAsset.assetName containsString: @"powerbeats"]) 
			{
				glyphName = @"batteryglyphs-powerbeats";
				imgsize = CGSizeMake(imgsize.width * 0.75, imgsize.height);
			}
			else if([device.glyph.imageAsset.assetName containsString: @"beats"]) glyphName = @"batteryglyphs-beats";

			if(glyphName) break;
		}
		
		if(glyphName) return [[[[%c(_UIAssetManager) assetManagerForBundle: [NSBundle bundleWithIdentifier: @"com.apple.BatteryCenter"]] imageNamed: glyphName] 
			sbf_resizeImageToSize: imgsize] imageWithRenderingMode: UIImageRenderingModeAlwaysTemplate];
		else return nil;
	}

	%hook UIImage

	+ (UIImage*)_kitImageNamed: (NSString*)name withTrait: (id)trait
	{
		UIImage *newImage;
		if([name containsString: @"BTHeadphones"]) newImage = getHeadphonesImage(%orig);
		
		if(newImage) return newImage;
		else return %orig();
	}

	- (UIImage*)_imageWithImageAsset: (UIImageAsset*)asset
	{
		UIImage *newImage;
		if([asset.assetName isEqualToString: @"headphones"] && [MSHookIvar<NSBundle*>(asset, "_containingBundle").bundleIdentifier isEqualToString: @"com.apple.CoreGlyphs"])
			newImage = getHeadphonesImage(%orig);
		
		if(newImage) return newImage;
		else return %orig();
	}

	%end

	%hook UIStatusBarIndicatorItemView

	- (UIImageView*)contentsImage
	{
		UIImage *newImage;
		UIImageView *imageView = %orig;
		if([self.item.indicatorName isEqualToString: @"BTHeadphones"] || [NSStringFromClass(self.item.viewClass) containsString: @"Bluetooth"])
			newImage = getHeadphonesImage(imageView.image);

		if(newImage) imageView.image = newImage;
		return imageView;
	}

	- (BOOL)shouldTintContentImage
	{
		if([self.item.indicatorName isEqualToString: @"BTHeadphones"] || [NSStringFromClass(self.item.viewClass) containsString: @"Bluetooth"])
			return true;
		return %orig;
	}

	%end

	%hook _UIStatusBarImageView

	- (UIImage*)image
	{
		return [%orig imageWithRenderingMode: UIImageRenderingModeAlwaysTemplate];
	}

	%end

%end

static void settingsChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
	NSDictionary *preferencesDictionary = [NSDictionary dictionaryWithContentsOfFile: @"/var/mobile/Library/Preferences/com.johnzaro.bluetoothbatteryinfoprefs.colors.plist"];
	customBackgroundColor = [SparkColourPickerUtils colourWithString: [preferencesDictionary objectForKey: @"customBackgroundColor"] withFallback: @"#000000:0.50"];
	glyphCustomTintColor = [SparkColourPickerUtils colourWithString: [preferencesDictionary objectForKey: @"glyphCustomTintColor"] withFallback: @"#FF9400:1.0"];
	customDeviceNameColor = [SparkColourPickerUtils colourWithString: [preferencesDictionary objectForKey: @"customDeviceNameColor"] withFallback: @"#FF9400:1.0"];
	customDefaultColor = [SparkColourPickerUtils colourWithString: [preferencesDictionary objectForKey: @"customDefaultColor"] withFallback: @"#FF9400"];
	chargingColor = [SparkColourPickerUtils colourWithString: [preferencesDictionary objectForKey: @"chargingColor"] withFallback: @"#26AD61"];
	lowPowerModeColor = [SparkColourPickerUtils colourWithString: [preferencesDictionary objectForKey: @"lowPowerModeColor"] withFallback: @"#F2C40F"];
	lowBattery1Color = [SparkColourPickerUtils colourWithString: [preferencesDictionary objectForKey: @"lowBattery1Color"] withFallback: @"#E57C21"];
	lowBattery2Color = [SparkColourPickerUtils colourWithString: [preferencesDictionary objectForKey: @"lowBattery2Color"] withFallback: @"#E84C3D"];

	if(showPercentSymbol) percentSymbol = @"%";
	else percentSymbol = @"";

	if(enableBlackListedApps)
		blackListedApps = [SparkAppList getAppListForIdentifier: @"com.johnzaro.bluetoothbatteryinfoprefs.blackListedApps" andKey: @"blackListedApps"];
	else
		blackListedApps = nil;

	if(bluetoothBatteryInfoObject)
	{
		[bluetoothBatteryInfoObject updateObjectWithNewSettings];
		[bluetoothBatteryInfoObject updateDeviceWithoutEffects];
		[bluetoothBatteryInfoObject updatePercentage];
	}
}

%ctor
{
	@autoreleasepool
	{
		pref = [[HBPreferences alloc] initWithIdentifier: @"com.johnzaro.bluetoothbatteryinfoprefs"];
		[pref registerBool: &enabled default: NO forKey: @"enabled"];
		if(enabled)
		{
			[pref registerBool: &showOnLockScreen default: NO forKey: @"showOnLockScreen"];
			[pref registerBool: &showOnlyOnLockScreen default: NO forKey: @"showOnlyOnLockScreen"];
			[pref registerBool: &showOnControlCenter default: NO forKey: @"showOnControlCenter"];
			[pref registerBool: &hideOnFullScreen default: NO forKey: @"hideOnFullScreen"];
			[pref registerBool: &hideOnLandscape default: NO forKey: @"hideOnLandscape"];
			[pref registerBool: &hideOnAppSwitcherFolder default: NO forKey: @"hideOnAppSwitcherFolder"];
			[pref registerBool: &notchlessSupport default: NO forKey: @"notchlessSupport"];
			[pref registerBool: &hideInternalBattery default: NO forKey: @"hideInternalBattery"];
			[pref registerBool: &hideGlyph default: NO forKey: @"hideGlyph"];
			[pref registerBool: &dynamicHeadphonesIcon default: NO forKey: @"dynamicHeadphonesIcon"];
			[pref registerBool: &hideBluetoothDevicesBatteryFromStatusBar default: NO forKey: @"hideBluetoothDevicesBatteryFromStatusBar"];
			[pref registerBool: &hideDeviceNameLabel default: NO forKey: @"hideDeviceNameLabel"];
			[pref registerBool: &showPercentSymbol default: NO forKey: @"showPercentSymbol"];
			[pref registerInteger: &glyphSize default: 20 forKey: @"glyphSize"];
			[pref registerBool: &enableGlyphCustomTintColor default: NO forKey: @"enableGlyphCustomTintColor"];
			[pref registerInteger: &percentageFontSize default: 10 forKey: @"percentageFontSize"];
			[pref registerBool: &percentageFontBold default: NO forKey: @"percentageFontBold"];
			[pref registerInteger: &nameFontSize default: 8 forKey: @"nameFontSize"];
			[pref registerBool: &nameFontBold default: NO forKey: @"nameFontBold"];
			[pref registerBool: &backgroundColorEnabled default: NO forKey: @"backgroundColorEnabled"];
			[pref registerInteger: &margin default: 3 forKey: @"margin"];
			[pref registerFloat: &backgroundCornerRadius default: 6 forKey: @"backgroundCornerRadius"];
			[pref registerBool: &customBackgroundColorEnabled default: NO forKey: @"customBackgroundColorEnabled"];
			[pref registerBool: &enableCustomDeviceNameColor default: NO forKey: @"enableCustomDeviceNameColor"];
			[pref registerFloat: &portraitX default: 165 forKey: @"portraitX"];
			[pref registerFloat: &portraitY default: 32 forKey: @"portraitY"];
			[pref registerFloat: &landscapeX default: 735 forKey: @"landscapeX"];
			[pref registerFloat: &landscapeY default: 32 forKey: @"landscapeY"];
			[pref registerBool: &followDeviceOrientation default: NO forKey: @"followDeviceOrientation"];
			[pref registerBool: &animateMovement default: NO forKey: @"animateMovement"];
			[pref registerBool: &enableBlackListedApps default: NO forKey: @"enableBlackListedApps"];
			[pref registerBool: &defaultColorEnabled default: NO forKey: @"defaultColorEnabled"];
			[pref registerBool: &chargingColorEnabled default: NO forKey: @"chargingColorEnabled"];
			[pref registerBool: &lowPowerModeColorEnabled default: NO forKey: @"lowPowerModeColorEnabled"];
			[pref registerBool: &lowBattery1ColorEnabled default: NO forKey: @"lowBattery1ColorEnabled"];
			[pref registerBool: &lowBattery2ColorEnabled default: NO forKey: @"lowBattery2ColorEnabled"];

			settingsChanged(NULL, NULL, NULL, NULL, NULL);
			CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, settingsChanged, CFSTR("com.johnzaro.bluetoothbatteryinfoprefs/ReloadPrefs"), NULL, CFNotificationSuspensionBehaviorCoalesce);
			if(hideBluetoothDevicesBatteryFromStatusBar)
				%init(hideBluetoothDevicesBatteryFromStatusBarGroup);
			if(dynamicHeadphonesIcon)
				%init(dynamicHeadphonesIconGroup);
			%init;
		}
	}
}