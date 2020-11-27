#import "PerfectTwitter.h"

#import <Cephei/HBPreferences.h>

static HBPreferences *pref;
static BOOL alwaysLatestTimeline;
static BOOL disablePromotions;

// -------------------------------- ALWAYS LATEST TIMELINE --------------------------------

%group alwaysLatestTimelineGroup

	%hook T1HomeTimelineVariantCoordinator

	- (_Bool)isLatestSwitchEnabled
	{
		return YES;
	}

	- (_Bool)_tfn_switchToTopTimePastThreshold:(double)arg1
	{
		return NO;
	}

	- (_Bool)shouldResetToTopTimeline
	{
		return NO;
	}

	- (void)setLatestHomeTimelineActive:(_Bool)arg1
	{
		%orig(true);
	}

	- (_Bool)isLatestHomeTimelineActive
	{
		return YES;
	}

	%end

%end

// -------------------------------- HIDE PROMO POSTS --------------------------------

// Code taken from @kemmis "twitter-no-ads" project

%group disablePromotionsGroup

	%hook TFNItemsDataViewController

	- (id)tableViewCellForItem: (id)v1 atIndexPath: (id)v2
	{
		UITableViewCell *tvCell = %orig;

		id item = [[self itemsInternalDataViewItemAtValidIndexPath: v2] item];
		if([item respondsToSelector: @selector(isPromoted)] && [item performSelector: @selector(isPromoted)]) [tvCell setHidden: YES];
		return tvCell;	
	}

	- (double)tableView: (id)arg1 heightForRowAtIndexPath: (id)arg2
	{
		id item = [self itemAtIndexPath: arg2];
		if([item respondsToSelector: @selector(isPromoted)] && [item performSelector: @selector(isPromoted)]) return 0;
		return %orig;
	}

	%end

%end

%ctor
{
	@autoreleasepool
	{
		pref = [[HBPreferences alloc] initWithIdentifier: @"com.johnzaro.perfecttwitterprefs"];

		[pref registerBool: &alwaysLatestTimeline default: YES forKey: @"alwaysLatestTimeline"];
		[pref registerBool: &disablePromotions default: YES forKey: @"disablePromotions"];

		if(alwaysLatestTimeline) %init(alwaysLatestTimelineGroup);
		if(disablePromotions) %init(disablePromotionsGroup);
	}
}
