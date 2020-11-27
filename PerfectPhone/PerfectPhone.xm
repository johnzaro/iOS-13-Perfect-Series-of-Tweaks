#import "PerfectPhone.h"
#import <Cephei/HBPreferences.h>
#import "SparkColourPickerUtils.h"

static HBPreferences *pref;
static BOOL enabled;
static BOOL showExactTimeInRecentCalls;
static BOOL hideThirdParyCalls;
static BOOL colorizeCalls;
static UIColor *incomingColor;
static UIColor *outgoingColor;
static UIColor *missedColor;
static BOOL longerCallButton;
static BOOL hideFavourites;
static BOOL hideRecents;
static BOOL hideContacts;
static BOOL hideKeypad;
static BOOL hideVoicemail;
static NSInteger defaultTab;

NSDateFormatter *dateFormatter;
CGFloat screenWidth;

// -------------------------- SHOW EXACT TIME IN RECENT CALLS --------------------------

%group showExactTimeInRecentCallsGroup

// Original Tweak by @gilshahar7: https://github.com/gilshahar7/ExactTimePhone

	%hook MPRecentsTableViewCell

	- (void)layoutSubviews
	{
		%orig;

		if(![[[self callerDateLabel] text] containsString: @":"])
		{
			[[self callerDateLabel] setTextAlignment: NSTextAlignmentRight];
			[[self callerDateLabel] setNumberOfLines: 2];
			[[self callerDateLabel] setText: [[[self callerDateLabel] text] stringByAppendingString: [dateFormatter stringFromDate: [[self callerDateLabel] date]]]];
		}
	}

	%end

%end

// -------------------------- HIDE THIRD PARTY CALLS FROM RECENT CALLS --------------------------

%group hideThirdParyCallsGroup

	%hook MobilePhoneApplication

	- (BOOL)showsThirdPartyRecents
	{
		return NO;
	}

	%end

%end

// -------------------------- COLORIZE RECENT CALLS --------------------------

%group coloredRecentCallsGroup

	// Original tweak by @leftyfl1p: https://github.com/leftyfl1p/ColorCodedLogs

	%hook MPRecentsTableViewController

	// incoming call = 1, answered elsewhere (another device) = 4, 
	// outgoing call = 2, outgoing but cancelled = 16

	- (id)tableView: (id)arg1 cellForRowAtIndexPath: (NSIndexPath*)arg2
	{
		MPRecentsTableViewCell *orig = %orig;

		UILabel *nameLabel = [[orig titleStackView] arrangedSubviews][0];
		CHRecentCall *callInfo = [self recentCallAtTableViewIndex: arg2.row];

		if([callInfo callStatus] == 1 || [callInfo callStatus] == 4)
			[nameLabel setTextColor: incomingColor];
		else if([callInfo callStatus] == 2 || [callInfo callStatus] == 16) 
			[nameLabel setTextColor: outgoingColor];
		else
			[nameLabel setTextColor: missedColor];

		return orig;
	}

	%end

%end

// -------------------------- LONGER CALL BUTTON --------------------------

%group longerCallButtonGroup

	%hook PHBottomBarButton

	- (void)layoutSubviews
	{
		%orig;

		CGRect newFrame = [self frame];
		newFrame.size.width = 282;
		newFrame.origin.x = screenWidth / 2.0 - newFrame.size.width / 2.0;
		[self setFrame: newFrame];

		[[[self overlayView] layer] setCornerRadius: [[self layer] cornerRadius]];
	}

	%end

	%hook PHHandsetDialerDeleteButton

	- (void)layoutSubviews
	{
		%orig;

		CGRect newFrame = [self frame];
		newFrame.origin.x = screenWidth / 2.0 - newFrame.size.width / 2.0;
		newFrame.origin.y = 187;
		[self setFrame: newFrame];
	}

	%end

%end

// -------------------------- HIDE TABS --------------------------

%group hideTabsGroup

	%hook PhoneTabBarController

	- (void)showFavoritesTab: (BOOL)tab recentsTab: (BOOL)tab2 contactsTab: (BOOL)tab3 keypadTab: (BOOL)tab4 voicemailTab: (BOOL)tab5
	{
		%orig(!hideFavourites, !hideRecents, !hideContacts, !hideKeypad, !hideVoicemail);
	}

	%end

%end

// -------------------------- CUSTOM DEFAULT OPENED TAB --------------------------

%group defaultTabGroup

	%hook PhoneTabBarController

	- (int)currentTabViewType
	{
		if(defaultTab == 1 && !hideFavourites 
		|| defaultTab == 2 && !hideRecents 
		|| defaultTab == 3 && !hideContacts 
		|| defaultTab == 4 && !hideKeypad
		|| defaultTab == 5 && !hideVoicemail)
			return defaultTab;
		else	
			return %orig;
	}

	- (int)defaultTabViewType
	{
		return defaultTab;
	}

	%end

%end

%ctor
{
	@autoreleasepool
	{
		pref = [[HBPreferences alloc] initWithIdentifier: @"com.johnzaro.perfectphoneprefs"];
		[pref registerDefaults:
		@{
			@"enabled": @NO,
			@"showExactTimeInRecentCalls": @NO,
			@"hideThirdParyCalls": @NO,
			@"colorizeCalls": @NO,
			@"longerCallButton": @NO,
			@"hideFavourites": @NO,
			@"hideRecents": @NO,
			@"hideContacts": @NO,
			@"hideKeypad": @NO,
			@"hideVoicemail": @NO,
			@"defaultTab": @1,
    	}];

		enabled = [pref boolForKey: @"enabled"];
		if(enabled)
		{
			showExactTimeInRecentCalls = [pref boolForKey: @"showExactTimeInRecentCalls"];
			hideThirdParyCalls = [pref boolForKey: @"hideThirdParyCalls"];
			colorizeCalls = [pref boolForKey: @"colorizeCalls"];
			longerCallButton = [pref boolForKey: @"longerCallButton"];
			hideFavourites = [pref boolForKey: @"hideFavourites"];
			hideRecents = [pref boolForKey: @"hideRecents"];
			hideContacts = [pref boolForKey: @"hideContacts"];
			hideKeypad = [pref boolForKey: @"hideKeypad"];
			hideVoicemail = [pref boolForKey: @"hideVoicemail"];
			defaultTab = [pref integerForKey: @"defaultTab"];

			if(showExactTimeInRecentCalls) 
			{
				dateFormatter = [[NSDateFormatter alloc] init];

				NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
				[formatter setLocale: [NSLocale currentLocale]];
				[formatter setDateStyle: NSDateFormatterNoStyle];
				[formatter setTimeStyle: NSDateFormatterShortStyle];
				NSString *dateString = [formatter stringFromDate: [NSDate date]];
				if([dateString rangeOfString: [formatter AMSymbol]].location == NSNotFound && [dateString rangeOfString: [formatter PMSymbol]].location == NSNotFound)
					[dateFormatter setDateFormat: @"\nHH:mm"];
				else
					[dateFormatter setDateFormat: @"\nh:mm a"];

				%init(showExactTimeInRecentCallsGroup);
			}

			if(hideThirdParyCalls)
				%init(hideThirdParyCallsGroup);

			if(colorizeCalls)
			{
				NSDictionary *preferencesDictionary = [NSDictionary dictionaryWithContentsOfFile: @"/var/mobile/Library/Preferences/com.johnzaro.perfectphoneprefs.colors.plist"];
				incomingColor = [SparkColourPickerUtils colourWithString: [preferencesDictionary objectForKey: @"incomingColor"] withFallback: @"#24579C"];
				outgoingColor = [SparkColourPickerUtils colourWithString: [preferencesDictionary objectForKey: @"outgoingColor"] withFallback: @"#007D00"];
				missedColor = [SparkColourPickerUtils colourWithString: [preferencesDictionary objectForKey: @"missedColor"] withFallback: @"#DA0000"];

				%init(coloredRecentCallsGroup);
			}
			
			if(longerCallButton)
			{
				screenWidth = [[UIScreen mainScreen] bounds].size.width;
				%init(longerCallButtonGroup);
			}

			if((hideFavourites || hideRecents || hideContacts || hideKeypad || hideVoicemail) && !(hideFavourites && hideRecents && hideContacts && hideKeypad)) 
				%init(hideTabsGroup);
			else
			{
				hideFavourites = NO;
				hideRecents = NO;
				hideContacts = NO;
				hideKeypad = NO;
				hideVoicemail = NO;
			}

			if(defaultTab < 1 || defaultTab > 4)
				defaultTab = 1;
			while(defaultTab == 1 && hideFavourites || defaultTab == 2 && hideRecents || defaultTab == 3 && hideContacts || defaultTab == 4 && hideKeypad)
			{
				defaultTab++;
				if(defaultTab == 5)
					defaultTab = 1;
			}
			%init(defaultTabGroup);
		}
	}
}