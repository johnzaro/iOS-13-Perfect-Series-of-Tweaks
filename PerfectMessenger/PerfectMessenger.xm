#import <Cephei/HBPreferences.h>

static HBPreferences *pref;
static BOOL enabled;
static BOOL removeStories;
static BOOL removeAds;
static BOOL hideTabBar;

@interface MSGThreadListDataSource: NSObject
- (NSArray*)inboxRows;
@end

%group removeRowsGroup

// Original Tweak by @haoict: https://github.com/haoict/messenger-no-ads

	%hook MSGThreadListDataSource

	- (NSArray*)inboxRows
	{  
		NSMutableArray *orig = [%orig mutableCopy];
		NSMutableIndexSet *indexesToRemove = [[NSMutableIndexSet alloc] init];

		if(removeStories)
			[indexesToRemove addIndex: 0];

		if(removeAds)
		{
			for(int i = 1; i < [orig count]; i++)
			{
				NSArray *row = orig[i];
				NSNumber *type = row[1];
				if([type intValue] == 2)
					[indexesToRemove addIndex: i];
			}
		}
		[orig removeObjectsAtIndexes: indexesToRemove];
		return [orig copy];
	}

	%end

%end

%group hideTabBarGroup

	%hook UITabBar

	- (void)layoutSubviews
	{
		[self setHidden: YES];
	}

	%end

%end

%ctor
{
	@autoreleasepool
	{
		pref = [[HBPreferences alloc] initWithIdentifier: @"com.johnzaro.perfectmessengerprefs"];
		[pref registerDefaults:
		@{
			@"enabled": @NO,
			@"removeStories": @NO,
			@"removeAds": @NO,
			@"hideTabBar": @NO
		}];

		enabled = [pref boolForKey: @"enabled"];
		if(enabled)
		{
			removeStories = [pref boolForKey: @"removeStories"];
			removeAds = [pref boolForKey: @"removeAds"];
			hideTabBar = [pref boolForKey: @"hideTabBar"];

			if(removeStories || removeAds) %init(removeRowsGroup);
			if(hideTabBar) %init(hideTabBarGroup);
		}
	}
}