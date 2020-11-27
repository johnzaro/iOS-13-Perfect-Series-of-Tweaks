#import "PerfectSettings.h"
#import <Cephei/HBPreferences.h>
#import <ifaddrs.h>
#import <arpa/inet.h>

extern void initPreferenceOrganizer();

static unsigned long long const BINARY_MEGABYTE = 1024 * 1024;
static double const DECIMAL_GIGABYTE = 1000 * 1000 * 1000;

static HBPreferences *pref;
static BOOL enabled;
static BOOL organizeSettings;
static BOOL enableCustomTitle;
static NSString *customTitle;
static BOOL roundSearchBar;
static BOOL hideSearchBar;
static BOOL disableEdgeToEdgeCells;
static BOOL hideArrow;
static BOOL hideCellSeparator;
static BOOL circleIcons;
static BOOL hideIcons;
static BOOL hideUpdateBadge;
static BOOL showWifiData;
static BOOL showCellularData;
static BOOL showDiskSpace;
static BOOL showBatteryHealth;

NSNumberFormatter *numberFormatter;

NSString *ipAddressString;
NSString *batteryHealthString;
NSString *cellularData;
NSString *storageData;

// GetInfo methods taken from tweak: https://github.com/shepgoba/SettingsWidgets by @shepgoba

static void getIPAddress()
{
	struct ifaddrs *interfaces = NULL;
	struct ifaddrs *temp_addr = NULL;
	
	if(getifaddrs(&interfaces) == 0)
	{
		temp_addr = interfaces;
		while(temp_addr != NULL)
		{
			if(temp_addr->ifa_addr->sa_family == AF_INET && !strcmp(temp_addr->ifa_name, "en0")) // Check if interface is en0 which is the wifi connection on the iPhone
			{
				ipAddressString = [NSString stringWithUTF8String: inet_ntoa(((struct sockaddr_in*)temp_addr->ifa_addr)->sin_addr)]; // Get NSString from C String
				break;
			}
			temp_addr = temp_addr->ifa_next;
		}
	}
	freeifaddrs(interfaces); // Free memory
}

static void getCellularData()
{
	CoreTelephonyClient *client = [[%c(PSUICoreTelephonyDataCache) sharedInstance] client];
	[client dataUsageForLastPeriods: 2 completion:
		^(CTDeviceDataUsage *dataUsage, NSError *arg2)
		{
			CTDataUsage *usage = [dataUsage totalDataUsageForPeriod: 0];
			unsigned long long actualDataUsageBytes = usage.cellularHome + usage.cellularRoaming;

			cellularData = [NSString stringWithFormat: @"%@ MB", [numberFormatter stringFromNumber: [NSNumber numberWithDouble: round(((float)actualDataUsageBytes / BINARY_MEGABYTE) * 100) / 100]]];
		}];
}

static void getStorageData()
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
	^{
		NSBundle *storageSettingsBundle = [NSBundle bundleWithPath: @"/System/Library/PreferenceBundles/StorageSettings.bundle"];
		[storageSettingsBundle load];

		STStorageDiskMonitor *monitor = [%c(STStorageDiskMonitor) new];
		if(monitor && [monitor respondsToSelector: @selector(updateDiskSpace)])
			[monitor updateDiskSpace];

		long long g_totalDiskSpace = monitor.deviceSize;
		long long g_usedDiskSpace = g_totalDiskSpace - monitor.lastFree;		
		storageData = [NSString stringWithFormat: @"%@ GB / %llu GB", [numberFormatter stringFromNumber: [NSNumber numberWithDouble: (double)(g_usedDiskSpace / DECIMAL_GIGABYTE)]], (uint64_t)(g_totalDiskSpace / DECIMAL_GIGABYTE)];
	});
}

static void getBatteryHealth()
{
	NSBundle *batteryUsageBundle = [NSBundle bundleWithPath: @"/System/Library/PreferenceBundles/BatteryUsageUI.bundle"];
	[batteryUsageBundle load];

	BatteryHealthUIController *healthUIController = [[[batteryUsageBundle classNamed: @"BatteryHealthUIController"] alloc] init];
	[healthUIController updateData];
	[healthUIController updateMaximumCapacity];

	int percentage = [healthUIController maximumCapacityPercent];
	if(percentage > 0 && percentage <= 100)
		batteryHealthString = [NSString stringWithFormat: @"%i%%", percentage];
	else
		batteryHealthString = @"N/A";
}

%group enableCustomTitleGroup

	%hook _UINavigationBarLargeTitleView

	- (void)setTitle: (NSString*)title
	{
		%orig(customTitle);
	}

	%end

	%hook _UINavigationBarContentView

	- (void)setTitle: (NSString*)title
	{
		if([self backButtonItem] || [[self _viewControllerForAncestor] isKindOfClass: %c(PSUIPrefsRootController)])
			%orig;
		else
			%orig(customTitle);
	}
	
	%end

%end

// ------------------------- BETTER SETTINGS UI -------------------------

%group disableEdgeToEdgeCellsGroup

	%hook PSListController

	- (void)setEdgeToEdgeCells: (BOOL)arg
	{
		%orig(NO);
	}

	- (BOOL)_isRegularWidth
	{
		return YES;
	}

	%end

%end

// ------------------------- CIRCLE ICONS -------------------------

%group editPSTableCellGroup

	%hook PSTableCell

	- (void)layoutSubviews
	{
		%orig;

		if(circleIcons && !hideIcons && [self imageView])
		{
			[[[self imageView] layer] setCornerRadius: 14.5]; // full width = 29
			[[[self imageView] layer] setMasksToBounds: YES];
		}

		if(hideArrow)
			[self setForceHideDisclosureIndicator: YES];
	}

	%end

%end

// ------------------------- HIDE CELL SEPARATORS -------------------------

%group hideCellSeparatorGroup

	%hook _UITableViewCellSeparatorView

	- (void)layoutSubviews
	{
		[self setHidden: YES];
	}

	%end

%end

// ------------------------- HIDE SEARCH BAR -------------------------

%group hideSearchBarGroup

	%hook PSKeyboardNavigationSearchController

	- (void)setSearchBar: (id)arg
	{

	}

	%end

%end

// ------------------------- ROUND SEARCH BAR -------------------------

%group roundSearchBarGroup

	%hook _UISearchBarSearchFieldBackgroundView

	- (void)setCornerRadius: (double)arg
	{
		%orig(40);
	}

	%end

%end

// ------------------------- HIDE ICONS -------------------------

%group hideIconsGroup

	%hook PSTableCell

	- (void)setIcon: (id)arg
	{
		
	}

	%end

%end

// ------------------------- HIDE SOFTWARE UPDATE BADGE -------------------------

%group hideUpdateBadgeGroup

	%hook PreferencesAppController

	- (void)updateSoftwareUpdateBadgeOnSpecifier: (id)arg1
	{

	}

	%end

%end

// ------------------------- SHOW MORE INFO ON MAIN SETTINGS PAGE -------------------------

%group showMoreInfoGroup // I have to find a better way of setting each value but it works for now

	%hook PSTableCell

	- (void)layoutSubviews
	{
		%orig;

		if(showWifiData && [[self specifier].identifier isEqualToString: @"WIFI"])
		{
			static dispatch_once_t onceToken;
			dispatch_once(&onceToken, ^{ getIPAddress(); });
			
			if(ipAddressString)
				[self setValue: ipAddressString];
		}
		else if(showCellularData && [[self specifier].identifier isEqualToString: @"MOBILE_DATA_SETTINGS_ID"])
		{
			static dispatch_once_t onceToken;
			dispatch_once(&onceToken, ^{ getCellularData(); });
			
			if(cellularData)
				[self setValue: cellularData];
		}
		else if(showDiskSpace && [[self specifier].identifier isEqualToString: @"General"])
		{
			static dispatch_once_t onceToken;
			dispatch_once(&onceToken, ^{ getStorageData(); });
			
			if(storageData)
				[self setValue: storageData];
		}
		else if(showBatteryHealth && [[self specifier].identifier isEqualToString: @"BATTERY_USAGE"])
		{
			static dispatch_once_t onceToken;
			dispatch_once(&onceToken, ^{ getBatteryHealth(); });

			if(batteryHealthString)
				[self setValue: batteryHealthString];
		}
	}

	%end

%end

%ctor
{
	pref = [[HBPreferences alloc] initWithIdentifier: @"com.johnzaro.perfectsettingsprefs"];
	[pref registerDefaults:
	@{
		@"enabled": @NO,
		@"tweaksTitle": @"Tweaks",
		@"systemAppsTitle": @"System Apps",
		@"appStoreAppsTitle": @"App Store Apps",
		@"enableCustomTitle": @NO,
		@"customTitle": @"PerfectSettings",
		@"disableEdgeToEdgeCells": @NO,
		@"circleIcons": @NO,
		@"hideIcons": @NO,
		@"hideArrow": @NO,
		@"hideCellSeparator": @NO,
		@"roundSearchBar": @NO,
		@"hideSearchBar": @NO,
		@"organizeSettings": @NO,
		@"hideUpdateBadge": @NO,
		@"showWifiData": @NO,
		@"showCellularData": @NO,
		@"showDiskSpace": @NO,
		@"showBatteryHealth": @NO,
	}];

	enabled = [pref boolForKey: @"enabled"];
	if(enabled)
	{
		enableCustomTitle = [pref boolForKey: @"enableCustomTitle"];
		customTitle = [pref objectForKey: @"customTitle"];
		disableEdgeToEdgeCells = [pref boolForKey: @"disableEdgeToEdgeCells"];
		circleIcons = [pref boolForKey: @"circleIcons"];
		hideIcons = [pref boolForKey: @"hideIcons"];
		hideArrow = [pref boolForKey: @"hideArrow"];
		hideCellSeparator = [pref boolForKey: @"hideCellSeparator"];
		roundSearchBar = [pref boolForKey: @"roundSearchBar"];
		hideSearchBar = [pref boolForKey: @"hideSearchBar"];
		organizeSettings = [pref boolForKey: @"organizeSettings"];
		hideUpdateBadge = [pref boolForKey: @"hideUpdateBadge"];
		showWifiData = [pref boolForKey: @"showWifiData"];
		showCellularData = [pref boolForKey: @"showCellularData"];
		showDiskSpace = [pref boolForKey: @"showDiskSpace"];
		showBatteryHealth = [pref boolForKey: @"showBatteryHealth"];

		if(showCellularData || showDiskSpace)
		{
			numberFormatter = [[NSNumberFormatter alloc] init];
			[numberFormatter setLocale: [NSLocale currentLocale]];
			[numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
			[numberFormatter setMaximumFractionDigits: 2];
		}

		if(organizeSettings)
			initPreferenceOrganizer();
		
		if(enableCustomTitle)
			%init(enableCustomTitleGroup);
		
		if(disableEdgeToEdgeCells)
			%init(disableEdgeToEdgeCellsGroup);
		
		if(circleIcons || hideArrow)
			%init(editPSTableCellGroup);
		
		if(hideIcons)
			%init(hideIconsGroup);
		
		if(hideCellSeparator)
			%init(hideCellSeparatorGroup);
		
		if(roundSearchBar)
			%init(roundSearchBarGroup);
		
		if(hideSearchBar)
			%init(hideSearchBarGroup);
		
		if(hideUpdateBadge)
			%init(hideUpdateBadgeGroup);
		
		if(showWifiData || showCellularData || showDiskSpace || showBatteryHealth)
			%init(showMoreInfoGroup);
	}
}