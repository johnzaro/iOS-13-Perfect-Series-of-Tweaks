#import "PerfectAutoLockInterval.h"
#import <Cephei/HBPreferences.h>

static HBPreferences *pref;
static BOOL enabled;
static BOOL customLockscreenLockedAutoLockInterval;
static BOOL customLockscreenNotDismissedAutoLockInterval;
static BOOL customDefaultAutoLockInterval;
static BOOL customChargingAutoLockInterval;
static BOOL customLowPowerAutoLockInterval;
static NSInteger lockScreenLockedAutoLockInterval;
static NSInteger lockScreenNotDismissedAutoLockInterval;
static NSInteger defaultAutoLockInterval;
static NSInteger chargingAutoLockInterval;
static NSInteger lowPowerAutoLockInterval;

static double autoLockIntervalsLockscreen[4] = {5, 10, 20, 30};
static double autoLockIntervals[7][2] = {{20, 30}, {40, 60}, {100, 120}, {160, 180}, {220, 240}, {280, 300}, {DBL_MAX, DBL_MAX}};

%hook SBIdleTimerDescriptor

- (double)warnInterval
{
	if([[%c(SBCoverSheetPresentationManager) sharedInstance] _isEffectivelyLocked] && customLockscreenLockedAutoLockInterval)
		return autoLockIntervalsLockscreen[lockScreenLockedAutoLockInterval];

	if(![[%c(SBCoverSheetPresentationManager) sharedInstance] hasBeenDismissedSinceKeybagLock] && customLockscreenNotDismissedAutoLockInterval)
		return autoLockIntervalsLockscreen[lockScreenNotDismissedAutoLockInterval];
	
	if([[%c(SBUIController) sharedInstance] isBatteryCharging] && customChargingAutoLockInterval)
		return autoLockIntervals[chargingAutoLockInterval][0];
	
	if([[NSProcessInfo processInfo] isLowPowerModeEnabled] && customLowPowerAutoLockInterval)
		return autoLockIntervals[lowPowerAutoLockInterval][0];

	if(customDefaultAutoLockInterval)
		return autoLockIntervals[defaultAutoLockInterval][0];
	
	return %orig;
}

- (double)totalInterval
{
	if([[%c(SBCoverSheetPresentationManager) sharedInstance] _isEffectivelyLocked] && customLockscreenLockedAutoLockInterval)
		return autoLockIntervalsLockscreen[lockScreenLockedAutoLockInterval];

	if(![[%c(SBCoverSheetPresentationManager) sharedInstance] hasBeenDismissedSinceKeybagLock] && customLockscreenNotDismissedAutoLockInterval)
		return autoLockIntervalsLockscreen[lockScreenNotDismissedAutoLockInterval];
	
	if([[%c(SBUIController) sharedInstance] isBatteryCharging] && customChargingAutoLockInterval)
		return autoLockIntervals[chargingAutoLockInterval][1];
	
	if([[NSProcessInfo processInfo] isLowPowerModeEnabled] && customLowPowerAutoLockInterval)
		return autoLockIntervals[lowPowerAutoLockInterval][1];

	if(customDefaultAutoLockInterval)
		return autoLockIntervals[defaultAutoLockInterval][1];
	
	return %orig;
}

%end

%ctor
{
	@autoreleasepool
	{
		pref = [[HBPreferences alloc] initWithIdentifier: @"com.johnzaro.customautolockintervalprefs"];
		[pref registerDefaults:
		@{
			@"enabled": @NO,
			@"customLockscreenLockedAutoLockInterval": @NO,
			@"customLockscreenNotDismissedAutoLockInterval": @NO,
			@"customDefaultAutoLockInterval": @NO,
			@"customChargingAutoLockInterval": @NO,
			@"customLowPowerAutoLockInterval": @NO,
			@"lockScreenLockedAutoLockInterval": @0,
			@"lockScreenNotDismissedAutoLockInterval": @0,
			@"defaultAutoLockInterval": @1,
			@"chargingAutoLockInterval": @1,
			@"lowPowerAutoLockInterval": @0,
    	}];

		enabled = [pref boolForKey: @"enabled"];
		if(enabled)
		{
			customLockscreenLockedAutoLockInterval = [pref boolForKey: @"customLockscreenLockedAutoLockInterval"];
			customLockscreenNotDismissedAutoLockInterval = [pref boolForKey: @"customLockscreenNotDismissedAutoLockInterval"];
			customDefaultAutoLockInterval = [pref boolForKey: @"customDefaultAutoLockInterval"];
			customChargingAutoLockInterval = [pref boolForKey: @"customChargingAutoLockInterval"];
			customLowPowerAutoLockInterval = [pref boolForKey: @"customLowPowerAutoLockInterval"];

			lockScreenLockedAutoLockInterval = [pref integerForKey: @"lockScreenLockedAutoLockInterval"];
			lockScreenNotDismissedAutoLockInterval = [pref integerForKey: @"lockScreenNotDismissedAutoLockInterval"];
			defaultAutoLockInterval = [pref integerForKey: @"defaultAutoLockInterval"];
			chargingAutoLockInterval = [pref integerForKey: @"chargingAutoLockInterval"];
			lowPowerAutoLockInterval = [pref integerForKey: @"lowPowerAutoLockInterval"];

			%init;
		}
	}
}