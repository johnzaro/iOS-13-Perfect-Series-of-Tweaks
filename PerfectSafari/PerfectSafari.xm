#import "PerfectSafari.h"
#import "SafariPreferences.h"
#import <Cephei/HBPreferences.h>

static SafariPreferences *preferences;

// enable full screen scroll

%group fullScreenGroup

	%hook BrowserController

	- (BOOL)fullScreenInPortrait
	{
		return YES;
	}

	%end

%end

// use tabs on iphone

%group alwaysShowTabsGroup

	%hook BrowserController

	- (BOOL)_shouldShowTabBar
	{
		return YES;
	}

	- (BOOL)_shouldUseTabBar
	{
		return YES;
	}

	%end

%end

// use tab overview on iphone + set 2 tabs per row in tab overview

%group useTabOverviewGroup

	%hook BrowserController

	- (BOOL)_shouldUseTabOverview
	{
		return YES;
	}

	%end

	%hook TabOverview

	- (unsigned long long)_tabsPerRow
	{
		return 2;
	}

	- (BOOL)showsPrivateBrowsingButton // visual fix
	{
		return NO;
	}

	%end

 %end

 // show bookmarks tab

%group showBookmarksBarGroup

	%hook BrowserController

	- (BOOL)_shouldShowBookmarksBar
	{
		return YES;
	}

	%end

 %end

// Background Playback

%group backgroundPlaybackGroup

	%hook WKContentView

	- (void)_applicationWillResignActive: (id)arg
	{

	}

	- (void)_applicationDidEnterBackground
	{

	}

	%end

%end

void initPerfectSafari()
{
	@autoreleasepool
	{
		preferences = [SafariPreferences sharedInstance];

		if([preferences fullScreen]) %init(fullScreenGroup);
		if([preferences alwaysShowTabs]) %init(alwaysShowTabsGroup);
		if([preferences useTabOverview] && ![preferences isIpad]) %init(useTabOverviewGroup);
		if([preferences showBookmarksBar]) %init(showBookmarksBarGroup);
		if([preferences backgroundPlayback]) %init(backgroundPlaybackGroup);
	}
}