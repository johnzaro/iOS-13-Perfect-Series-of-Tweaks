#import "PerfectBattery.h"
#import <Cephei/HBPreferences.h>
#import "SparkColourPickerUtils.h"
#import "SparkAppList.h"

static HBPreferences *pref;
static BOOL enabled;
static long doubleTapAction;
static NSString *doubleTapIdentifier;
static long holdAction;
static NSString *holdIdentifier;
static long style;
static long fontSize;
static BOOL boldFont;
static BOOL showPercentSymbol;
static BOOL customDefaultColorEnabled;
static UIColor *customDefaultColor;
static UIColor *chargingColor;
static UIColor *lowPowerModeColor;
static UIColor *lowBattery1Color;
static UIColor *lowBattery2Color;

static NSString *percentSymbol;

static void switchLPM()
{
	if([[NSProcessInfo processInfo] isLowPowerModeEnabled])
		[[%c(_CDBatterySaver) batterySaver] setPowerMode: 0 error: nil];
	else
		[[%c(_CDBatterySaver) batterySaver] setPowerMode: 1 error: nil];

	if([[UIDevice currentDevice] _feedbackSupportLevel] >= 1)
	{
		UIImpactFeedbackGenerator *gen = [[UIImpactFeedbackGenerator alloc] initWithStyle: UIImpactFeedbackStyleLight];
		[gen prepare];
		[gen impactOccurred];
	}
}

static void openBatteryUsagePage()
{
	[[UIApplication sharedApplication] openURL: [NSURL URLWithString: @"Prefs:root=BATTERY_USAGE"]];
}

static void openApp(NSString *identifier)
{
	[[UIApplication sharedApplication] launchApplicationWithIdentifier: identifier suspended: NO];
}

%group batteryActionsGroup

	%hook _UIBatteryView

	- (void)layoutSubviews
	{
		%orig;
		[self setUserInteractionEnabled: YES];

		if(![[self hasGestureRecognizer] isEqual: @YES])
		{
			if(doubleTapAction > 0)
			{
				UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(fireDoubleTapAction)];
				[tapGestureRecognizer setNumberOfTapsRequired: 2];
				[self addGestureRecognizer: tapGestureRecognizer];
			}
			if(holdAction > 0)
			{
				UILongPressGestureRecognizer *holdGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget: self action: @selector(fireHoldAction)];
				[self addGestureRecognizer: holdGestureRecognizer];
			}
			[self setHasGestureRecognizer: @YES];
		}
	}

	%new
	- (void)fireDoubleTapAction
	{
		if(doubleTapAction == 1)
			switchLPM();
		else if(doubleTapAction == 2)
			openBatteryUsagePage();
		else if(doubleTapAction == 3)
			openApp(doubleTapIdentifier);
	}

	%new
	- (void)fireHoldAction
	{
		if(holdAction == 1)
			switchLPM();
		else if(holdAction == 2)
			openBatteryUsagePage();
		else if(holdAction == 3)
			openApp(holdIdentifier);
	}

	%new
	- (id)hasGestureRecognizer
	{
		return objc_getAssociatedObject(self, @selector(hasGestureRecognizer));
	}

	%new
	- (void)setHasGestureRecognizer: (id)arg
	{
		objc_setAssociatedObject(self, @selector(hasGestureRecognizer), arg, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}

	%end

%end

// show battery percentage inside battery icon
%group showBatteryIconGroup

	%hook _UIBatteryView

	- (void)setShowsPercentage: (BOOL)arg
	{
		%orig(YES);
	}

	- (BOOL)showsPercentage
	{
		return YES;
	}

	// Hide bolt symbol while charging
	- (void)setShowsInlineChargingIndicator: (BOOL)showing
	{
		%orig(NO);
	}

	%end

%end

// hide battery icon, show percentage label instead
%group hideBatteryIconGroup

	%hook _UIBatteryView

	%property (nonatomic, retain) UILabel *percentLabel;
	%property (nonatomic, retain) UIColor *backupFillColor;

	- (id)initWithFrame: (CGRect)frame
	{
		self = %orig;
		
		[self setPercentLabel: [[UILabel alloc] initWithFrame: CGRectMake(0, 0, 35, 12)]];
		if(boldFont) [[self percentLabel] setFont: [UIFont boldSystemFontOfSize: fontSize]];
		else [[self percentLabel] setFont: [UIFont systemFontOfSize: fontSize]];
		[[self percentLabel] setAdjustsFontSizeToFitWidth: YES];
		[[self percentLabel] setTextAlignment: NSTextAlignmentLeft];
		[[self percentLabel] setText: [NSString stringWithFormat:@"%.0f%@", floor(self.chargePercent * 100), percentSymbol]];
		[self addSubview: [self percentLabel]];

		return self;
	}

	- (void)setChargePercent: (CGFloat)percent
	{
		%orig;
		[[self percentLabel] setText: [NSString stringWithFormat:@"%.0f%@", floor(percent * 100), percentSymbol]];
	}

	// Update percentage label color in various events
	%new
	- (void)updatePercentageColor
	{
		if([self chargingState] != 0) [[self percentLabel] setTextColor: chargingColor];
		else if([self saverModeActive]) [[self percentLabel] setTextColor: lowPowerModeColor];
		else if([self chargePercent] <= 0.15) [[self percentLabel] setTextColor: lowBattery2Color];
		else if([self chargePercent] <= 0.25) [[self percentLabel] setTextColor: lowBattery1Color];
		else if(customDefaultColorEnabled) [[self percentLabel] setTextColor: customDefaultColor];
		else [[self percentLabel] setTextColor: [self backupFillColor]];
	}

	- (void)setChargingState: (long long)arg1
	{
		%orig;
		[self updatePercentageColor];
	}

	- (void)setSaverModeActive: (BOOL)arg1
	{
		%orig;
		[self updatePercentageColor];
	}

	- (void)_updateFillLayer
	{
		%orig;
		[self updatePercentageColor];
	}

	// Do not update any color automatically
	- (void)_updateFillColor
	{

	}

	- (void)_updateBodyColors
	{

	}

	- (void)_updateBatteryFillColor
	{

	}

	// Return clear fill color but keep a backup of it
	- (void)setFillColor: (UIColor*)arg1
	{
		[self setBackupFillColor: arg1];
		%orig([UIColor clearColor]);
	}

	- (UIColor*)fillColor
	{
		return [UIColor clearColor];
	}

	// Hide body component completely
	- (void)setBodyColor: (UIColor*)arg1
	{
		%orig([UIColor clearColor]);
	}

	- (UIColor*)bodyColor
	{
		return [UIColor clearColor];
	}

	// Hide pin component completely
	- (void)setPinColor: (UIColor*)arg1
	{
		%orig([UIColor clearColor]);
	}

	- (UIColor*)pinColor
	{
		return [UIColor clearColor];
	}

	- (CAShapeLayer*)pinShapeLayer
	{
		return nil;
	}

	// Hide bolt symbol while charging
	- (void)setShowsInlineChargingIndicator: (BOOL)showing
	{
		%orig(NO);
	}

	%end

%end

// Hide duplicate percentage label from control center
%group hidePercentageForStringViewGroup
	
	%hook _UIStatusBarStringView

	- (void)setText: (NSString*)text
	{
		if(![text containsString: @"%"])
			%orig;
	}

	%end

%end

%ctor
{
	@autoreleasepool
	{
		pref = [[HBPreferences alloc] initWithIdentifier: @"com.johnzaro.perfectbattery13prefs"];
		[pref registerDefaults:
		@{
			@"enabled": @NO,
			@"doubleTapAction": @0,
			@"holdAction": @0,
			@"style": @0,
			@"fontSize": @14,
			@"boldFont": @NO,
			@"showPercentSymbol": @NO,
			@"customDefaultColorEnabled": @NO,
    	}];

		enabled = [pref boolForKey: @"enabled"];
		if(enabled)
		{
			doubleTapAction = [pref integerForKey: @"doubleTapAction"];
			holdAction = [pref integerForKey: @"holdAction"];

			if(doubleTapAction > 0 || holdAction > 0)
			{
				if(doubleTapAction == 3)
				{
					NSArray *doubleTapApp = [SparkAppList getAppListForIdentifier: @"com.johnzaro.perfectbattery13prefs.gestureApps" andKey: @"doubleTapApp"];
					if(doubleTapApp && [doubleTapApp count] == 1)
						doubleTapIdentifier = doubleTapApp[0];
				}

				if(holdAction == 3)
				{
					NSArray *holdApp = [SparkAppList getAppListForIdentifier: @"com.johnzaro.perfectbattery13prefs.gestureApps" andKey: @"holdApp"];
					if(holdApp && [holdApp count] == 1)
						holdIdentifier = holdApp[0];
				}

				%init(batteryActionsGroup);
			}

			style = [pref integerForKey: @"style"];
			if(style != 0)
			{
				%init(hidePercentageForStringViewGroup);

				if(style == 1)
					%init(showBatteryIconGroup);
				else if(style == 2)
				{
					fontSize = [pref integerForKey: @"fontSize"];
					boldFont = [pref boolForKey: @"boldFont"];
					showPercentSymbol = [pref boolForKey: @"showPercentSymbol"];

					if(showPercentSymbol) percentSymbol = @"%";
					else percentSymbol = @"";

					NSDictionary *preferencesDictionary = [NSDictionary dictionaryWithContentsOfFile: @"/var/mobile/Library/Preferences/com.johnzaro.perfectbattery13prefs.colors.plist"];
					
					customDefaultColor = [SparkColourPickerUtils colourWithString: [preferencesDictionary objectForKey: @"customDefaultColor"] withFallback: @"#FF9400"];
					chargingColor = [SparkColourPickerUtils colourWithString: [preferencesDictionary objectForKey: @"chargingColor"] withFallback: @"#26AD61"];
					lowPowerModeColor = [SparkColourPickerUtils colourWithString: [preferencesDictionary objectForKey: @"lowPowerModeColor"] withFallback: @"#F2C40F"];
					lowBattery1Color = [SparkColourPickerUtils colourWithString: [preferencesDictionary objectForKey: @"lowBattery1Color"] withFallback: @"#E57C21"];
					lowBattery2Color = [SparkColourPickerUtils colourWithString: [preferencesDictionary objectForKey: @"lowBattery2Color"] withFallback: @"#E84C3D"];

					%init(hideBatteryIconGroup);
				}
			}
		}
	}
}