#import "PerfectReddit.h"
#import <Cephei/HBPreferences.h>
#import "SparkColourPickerUtils.h"

static HBPreferences *pref;
static BOOL disablePromotions;
static BOOL disableSuggestions;
static BOOL disableCommentHiding;
static BOOL hideCoinButton;
static BOOL hideLiveBroadcasts;
static BOOL customTheme;
static UIColor *mainColor;
static UIColor *secondaryColor;
static UIColor *textColor;

%group disablePromotionsGroup

	%hook Post

	- (BOOL)isHidden
	{
		if([self isKindOfClass:[%c(AdPost) class]])
			return YES;
		else
			return %orig;
	}

	%end

%end

%group disableSuggestionsGroup

	%hook Carousel

	- (BOOL)isHiddenByUserWithAccountSettings: (id)arg1
	{
		return YES;
	}

	%end

%end

%group disableCommentHidingGroup

	%hook CommentTreeHeaderNode

	- (void)didSingleTap: (id)arg
	{

	}

	- (void)didLongPress: (id)arg
	{

	}

	- (void)didLongTapComment: (id)arg
	{

	}

	%end

%end

%group hideLiveBroadcastsGroup

	%hook StreamingUnitDataProvider

	- (BOOL)shouldHideUnit
	{
		return YES;
	}

	%end

%end

%group hideCoinButtonGroup

	%hook CoinSaleEntryContainer

	- (id)init
	{
		return nil;
	}

	%end

%end

%group customThemeGroup

	// ------------------------------- MAIN COLOR -------------------------------

	%hook _TtC8RedditUI10ColorGuide

	- (UIColor*)tone1
	{
		return mainColor;
	}

	%end

	%hook MintTheme

	- (UIColor*)inactiveColor
	{
		return mainColor;
	}

	- (UIColor*)logoColor
	{
		return mainColor;
	}

	- (UIColor*)activeColor
	{
		return mainColor;
	}

	- (UIColor*)buttonColor
	{
		return mainColor;
	}

	- (UIColor*)shareSheetDimmerColor
	{
		return mainColor;
	}

	- (UIColor*)dimmerColor
	{
		return mainColor;
	}

	- (UIColor*)toastColor
	{
		return mainColor;
	}

	- (UIColor*)linkTextColor
	{
		return mainColor;
	}

	- (UIColor*)actionColor
	{
		return mainColor;
	}

	- (UIColor*)navIconColor
	{
		return mainColor;
	}

	// ------------------------------- SECONDARY-LIGHT COLOR -------------------------------

	- (UIColor*)canvasColor
	{
		return secondaryColor;
	}

	- (UIColor*)fieldColor
	{
		return secondaryColor;
	}

	- (UIColor*)buttonHighlightTextColor
	{
		return secondaryColor;
	}

	- (UIColor*)cellHighlightColor
	{
		return secondaryColor;
	}

	- (UIColor*)lineColor
	{
		return secondaryColor;
	}

	- (UIColor*)highlightColor
	{
		return secondaryColor;
	}

	- (UIColor*)listBackgroundColor
	{
		return secondaryColor;
	}

	- (UIColor*)loadingPlaceHolderColor
	{
		return secondaryColor;
	}

	// ------------------------------- TEXT-DARK COLOR -------------------------------
	
	- (UIColor*)bodyTextColor
	{
		return textColor;
	}

	- (UIColor*)buttonTextColor
	{
		return textColor;
	}

	- (UIColor*)metaTextColor
	{
		return textColor;
	}

	- (UIColor*)flairTextColor
	{
		return textColor;
	}

	%end

%end

%ctor
{
	@autoreleasepool
	{
		pref = [[HBPreferences alloc] initWithIdentifier: @"com.johnzaro.perfectredditprefs"];
		[pref registerDefaults:
		@{
			@"disablePromotions": @NO,
			@"disableSuggestions": @NO,
			@"disableCommentHiding": @NO,
			@"hideCoinButton": @NO,
			@"hideLiveBroadcasts": @NO,
			@"customTheme": @NO
    	}];

		disablePromotions = [pref boolForKey: @"disablePromotions"];
		disableSuggestions = [pref boolForKey: @"disableSuggestions"];
		disableCommentHiding = [pref boolForKey: @"disableCommentHiding"];
		hideCoinButton = [pref boolForKey: @"hideCoinButton"];
		hideLiveBroadcasts = [pref boolForKey: @"hideLiveBroadcasts"];
		customTheme = [pref boolForKey: @"customTheme"];

		if(disablePromotions)
			%init(disablePromotionsGroup);
		if(disableSuggestions)
			%init(disableSuggestionsGroup);
		if(disableCommentHiding)
			%init(disableCommentHidingGroup);
		if(hideCoinButton)
			%init(hideCoinButtonGroup, CoinSaleEntryContainer = NSClassFromString(@"Economy.CoinSaleEntryContainer"));
		if(hideLiveBroadcasts)
			%init(hideLiveBroadcastsGroup);
		if(customTheme)
		{
			NSDictionary *preferencesDictionary = [NSDictionary dictionaryWithContentsOfFile: @"/var/mobile/Library/Preferences/com.johnzaro.perfectredditprefs.colors.plist"];
			
			mainColor = [SparkColourPickerUtils colourWithString: [preferencesDictionary objectForKey: @"mainColor"] withFallback: @"#FF9400"];
			secondaryColor = [SparkColourPickerUtils colourWithString: [preferencesDictionary objectForKey: @"secondaryColor"] withFallback: @"#FFFAE6"];
			textColor = [SparkColourPickerUtils colourWithString: [preferencesDictionary objectForKey: @"textColor"] withFallback: @"#663B00"];
			
			%init(customThemeGroup);
		}
	}
}