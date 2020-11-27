#import "ControlCenterPreferences.h"

#define IS_iPAD ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

@implementation ControlCenterPreferences

+ (id)sharedInstance
{
	static ControlCenterPreferences *sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, 
	^{
		sharedInstance = [[ControlCenterPreferences alloc] init];
	});
	return sharedInstance;
}

- (id)init
{
	self = [super init];

	_preferences = [[HBPreferences alloc] initWithIdentifier: @"com.johnzaro.perfectcontrolcenterprefs"];
	[_preferences registerDefaults:
	@{
		@"enabled": @NO,
		@"roundCCModules": @NO,
		@"showSliderPercentage": @NO,
		@"hideControlCenterStatusBar": @NO,
		@"moveControlCenterToTheBottom": @NO,
		@"turnOffOnTap": @NO,
		@"customConnectivitySizeEnabled": @NO,
		@"connectivityRows": @2,
		@"connectivityColumns": @2,
		@"customMusicSizeEnabled": @NO,
		@"musicSize": @1,
		@"respringConfirmation": @NO,
		@"ldRestartConfirmation": @NO,
		@"safeModeConfirmation": @NO,
		@"uiCacheConfirmation": @NO,
		@"powerOffConfirmation": @NO,
		@"rebootConfirmation": @NO,
	}];

	_enabled = [_preferences boolForKey: @"enabled"];

	_roundCCModules = [_preferences boolForKey: @"roundCCModules"];
	_showSliderPercentage = [_preferences boolForKey: @"showSliderPercentage"];
	_hideControlCenterStatusBar = [_preferences boolForKey: @"hideControlCenterStatusBar"];
	_moveControlCenterToTheBottom = [_preferences boolForKey: @"moveControlCenterToTheBottom"];
	_turnOffOnTap = [_preferences boolForKey: @"turnOffOnTap"];
	_customConnectivitySizeEnabled = [_preferences boolForKey: @"customConnectivitySizeEnabled"];
	_connectivityRows = [_preferences integerForKey: @"connectivityRows"];
	_connectivityColumns = [_preferences integerForKey: @"connectivityColumns"];
	_customMusicSizeEnabled = [_preferences boolForKey: @"customMusicSizeEnabled"];
	_musicSize = [_preferences integerForKey: @"musicSize"];
	_respringConfirmation = [_preferences boolForKey: @"respringConfirmation"];
	_ldRestartConfirmation = [_preferences boolForKey: @"ldRestartConfirmation"];
	_safeModeConfirmation = [_preferences boolForKey: @"safeModeConfirmation"];
	_uiCacheConfirmation = [_preferences boolForKey: @"uiCacheConfirmation"];
	_powerOffConfirmation = [_preferences boolForKey: @"powerOffConfirmation"];
	_rebootConfirmation = [_preferences boolForKey: @"rebootConfirmation"];

	return self;
}

- (BOOL)isIpad
{
	return IS_iPAD;
}

@end