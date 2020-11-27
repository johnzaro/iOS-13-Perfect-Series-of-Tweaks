#import "PerfectAppSwitcher.h"
#import <Cephei/HBPreferences.h>

#define IS_iPAD ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

static HBPreferences *pref;
static BOOL enabled;
static BOOL gridSwitcher;
static BOOL disablePlayingMediaKilling;
static BOOL enableKillAll;
static NSInteger swipeSpeed;
static BOOL hideAppName;
static BOOL hideAppIcon;
static float appScale;
static NSInteger horizontalPortraitSpace;
static NSInteger verticalPortraitSpace;
static NSInteger horizontalLandscapeSpace;
static NSInteger verticalLandscapeSpace;

// ------------------------------ CUSTOM GRID SWITCHER - iPAD STYLE ------------------------------

%group gridSwitcherGroup

	%hook SBAppSwitcherSettings

	- (void)setGridSwitcherPageScale: (double)arg
	{
		%orig(appScale);
	}

	- (void)setGridSwitcherHorizontalInterpageSpacingPortrait: (double)arg
	{
		%orig(horizontalPortraitSpace);
	}

	- (void)setGridSwitcherVerticalNaturalSpacingPortrait: (double)arg
	{
		%orig(verticalPortraitSpace);
	}

	- (void)setGridSwitcherHorizontalInterpageSpacingLandscape: (double)arg
	{
		%orig(horizontalLandscapeSpace);
	}

	- (void)setGridSwitcherVerticalNaturalSpacingLandscape: (double)arg
	{
		%orig(verticalLandscapeSpace);
	}

	- (void)setSwitcherStyle: (long long)arg
	{
		%orig(2);
	}

	%end

%end

// ------------------------------ Disable Killing Of Playing App ------------------------------

%group disablePlayingMediaKillingGroup

	%hook SBFluidSwitcherItemContainer

	- (void)layoutSubviews
	{
		%orig;

		SBMediaController *media = [%c(SBMediaController) sharedInstance];

		if(media && [media isPlaying])
		{
			SBFluidSwitcherItemContainerHeaderItem *allAppCards = [self headerItems];

			NSString *nowPlayingApp = [[media nowPlayingApplication] displayName];

			for(SBFluidSwitcherItemContainerHeaderItem *appCard in allAppCards)
			{
				if([[appCard titleText] isEqualToString: nowPlayingApp]) [self setKillable: NO];
			}
		}
	}

	%end

%end

// ------------------------------ KILL ALL RUNNING APPS ------------------------------

%group enableKillAllGroup

	%hook SBFluidSwitcherItemContainer

	- (void)scrollViewWillEndDragging: (id)arg1 withVelocity: (CGPoint)arg2 targetContentOffset: (CGPoint*)arg3
	{
		if(arg2.y < swipeSpeed)
		{
			SBMainSwitcherViewController *mainSwitcher = [%c(SBMainSwitcherViewController) sharedInstance];
			NSArray *items = [mainSwitcher recentAppLayouts];

			SBMediaController *media = [%c(SBMediaController) sharedInstance];
			NSString *nowPlayingID = [[media nowPlayingApplication] bundleIdentifier];

			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), 
			^{
				for(SBAppLayout *item in items)
				{
					if(disablePlayingMediaKilling && [media isPlaying] && [[[[item rolesToLayoutItemsMap] objectForKey: @1] bundleIdentifier] isEqualToString: nowPlayingID])
						continue;
					
					[mainSwitcher _deleteAppLayout: item forReason: 1];
				}
			});
		}
		%orig;
	}

	%end

%end

%group hideAppNameGroup

	%hook SBFluidSwitcherItemContainerHeaderView

	- (void)setTextAlpha: (double)arg1
	{
		%orig(0);
	}

	%end

%end

%group hideAppIconGroup

	%hook SBFluidSwitcherIconImageContainerView

	- (void)layoutSubviews
	{
		
	}

	%end

%end

%ctor
{
	@autoreleasepool
	{
		pref = [[HBPreferences alloc] initWithIdentifier: @"com.johnzaro.perfectappswitcher13prefs"];
		[pref registerDefaults:
		@{
			@"enabled": @NO,
			@"gridSwitcher": @NO,
			@"disablePlayingMediaKilling": @NO,
			@"enableKillAll": @NO,
			@"swipeSpeed": @-5,
			@"hideAppName": @NO,
			@"hideAppIcon": @NO,
			@"appScale": @0.38,
			@"horizontalPortraitSpace": @30,
			@"verticalPortraitSpace": @65,
			@"horizontalLandscapeSpace": @10,
			@"verticalLandscapeSpace": @40
    	}];

		enabled = [pref boolForKey: @"enabled"];
		if(enabled)
		{
			gridSwitcher = [pref boolForKey: @"gridSwitcher"];
			disablePlayingMediaKilling = [pref boolForKey: @"disablePlayingMediaKilling"];
			enableKillAll = [pref boolForKey: @"enableKillAll"];
			swipeSpeed = [pref integerForKey: @"swipeSpeed"];
			hideAppName = [pref boolForKey: @"hideAppName"];
			hideAppIcon = [pref boolForKey: @"hideAppIcon"];

			if(gridSwitcher && !IS_iPAD)
			{
				appScale = [pref floatForKey: @"appScale"];
				horizontalPortraitSpace = [pref integerForKey: @"horizontalPortraitSpace"];
				verticalPortraitSpace = [pref integerForKey: @"verticalPortraitSpace"];
				horizontalLandscapeSpace = [pref integerForKey: @"horizontalLandscapeSpace"];
				verticalLandscapeSpace = [pref integerForKey: @"verticalLandscapeSpace"];

				%init(gridSwitcherGroup);
			}
			if(disablePlayingMediaKilling) %init(disablePlayingMediaKillingGroup);
			if(enableKillAll) %init(enableKillAllGroup);
			if(hideAppName) %init(hideAppNameGroup);
			if(hideAppIcon) %init(hideAppIconGroup);
		}
	}
}