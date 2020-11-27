#import "PerfectYoutube.h"

#import <Cephei/HBPreferences.h>

static HBPreferences *pref;
static BOOL backgroundPlayback;
static BOOL disableInVideoAds;
static BOOL allowHDOnCellular;
static BOOL noPopupsOnVideoEnd;
static BOOL hideDarkBackgroundOverlayInVideo;
static BOOL showProgressBarInVideo;
static BOOL hideComments;
static BOOL hideDownloadButton;
static BOOL hideCreateVideoButton;
static BOOL hideCastButton;
static BOOL hideVoiceSearchButton;
static BOOL hideExploreTab;
static BOOL hideSubscriptionsTab;
static BOOL hideInboxTab;
static BOOL hideLibraryTab;
static BOOL hideStories;
static BOOL disableHints;
static BOOL showStatusBarOnLandscape;

// ENABLE BACKGROUND PLAYBACK

%group backgroundPlaybackGroup

	%hook YTSingleVideo

	- (BOOL)isPlayableInBackground
	{
		return YES;
	}

	%end

	%hook YTPlaybackData

	- (BOOL)isPlayableInBackground
	{
		return YES;
	}

	%end

	%hook YTPlaybackBackgroundTaskController

	- (BOOL)isContentPlayableInBackground
	{
		return YES;
	}

	%end

	%hook YTIPlayerResponse

	- (BOOL)isPlayableInBackground
	{
		return YES;
	}

	%end

	%hook YTIPlayabilityStatus

	- (BOOL)isPlayableInBackground
	{
		return YES;
	}

	%end

	%hook YTPlaybackBackgroundTaskController

	- (void)setContentPlayableInBackground: (BOOL)arg
	{
		%orig(YES);
	}

	%end

%end

// DISABLE ADS

%group disableInVideoAdsGroup

	%hook YTIPlayerResponse

	- (BOOL)isMonetized
	{
		return NO;
	}

	%end

%end

// NO POPUPS ON VIDEO END

%group noPopupsOnVideoEndGroup

	%hook YTCreatorEndscreenView

	- (id)initWithFrame: (CGRect)arg1
	{
		return 0;
	}

	%end

%end

// HIDE DARK BACKGROUND OVERLAY WHEN SHOWING VIDEO CONTROLS

%group hideDarkBackgroundOverlayInVideoGroup

	%hook YTMainAppVideoPlayerOverlayView

	- (void)setBackgroundVisible: (BOOL)arg
	{
		%orig(NO);
	}

	%end

%end

// HIDE COMMENTS SECTION

%group hideCommentsGroup

	%hook YTCommentSectionControllerBuilder

	- (void)loadSectionController: (id)arg1 withModel: (id)arg2
	{

	}

	%end

%end

// SHOW VIDEO PROGRESS BAR WHILE PLAYING VIDEO

%group showProgressBarInVideoGroup

	%hook YTPlayerBarController

	- (void)setPlayerViewLayout: (int)arg1
	{
		%orig(2);
	}

	%end

	%hook YTMainAppVideoPlayerOverlayViewController

	- (void)adjustPlayerBarPositionForRelatedVideos
	{
		
	}

	%end

	%hook YTRelatedVideosViewController

	- (void)setEnabled: (BOOL)arg
	{
		%orig(NO);
	}

	- (BOOL)isEnabled
	{
		return NO;
	}

	%end

%end

// HIDE DOWNLOAD BUTTON

%group hideDownloadButtonGroup

	%hook YTTransferButton

	- (void)setVisible: (_Bool)arg1 dimmed: (_Bool)arg2
	{
		%orig(NO, NO);
	}

	%end

%end

// HIDE CREATE VIDEO BUTTON

%group hideCreateVideoButtonGroup

	%hook YTRightNavigationButtons

	- (void)layoutSubviews
	{
		%orig;
		
		if(![[self creationButton] isHidden]) [[self creationButton] setHidden: YES];
	}

	%end

%end

// HIDE CAST BUTTON

%group hideCastButtonGroup

	%hook YTSettings

	- (void)setDisableMDXDeviceDiscovery:(_Bool)arg1
	{
		%orig(YES);
	}

	%end

	%hook MDXPlaybackRouteButtonController

	- (_Bool)isPersistentCastIconEnabled
	{
		return NO;
	}

	- (void)updateButton:(id)arg1
	{

	}

	%end

%end

// HIDE VOICE SEARCH BUTTON

%group hideVoiceSearchButtonGroup

	%hook YTSearchTextField

	- (void)setVoiceSearchEnabled:(_Bool)arg1
	{
		%orig(NO);
	}

	%end

%end

// ALLOW HD ON CELLULAR

%group allowHDOnCellularGroup

	%hook YTSettings

	- (BOOL)disableHDOnCellular
	{
		return NO;
	}

	- (void)setDisableHDOnCellular: (BOOL)arg
	{
		%orig(NO);
	}

	%end

%end

// HIDE EXPLORE ||  SUBSCRIPTIONS || INBOX || LIBRARY TAB

%group hideTabGroup

	%hook YTPivotBarView

	- (void)layoutSubviews
	{
		%orig;

		if(hideExploreTab) MSHookIvar<YTPivotBarItemView*>(self, "_itemView2").hidden = YES;
		if(hideSubscriptionsTab) MSHookIvar<YTPivotBarItemView*>(self, "_itemView3").hidden = YES;
		if(hideInboxTab) MSHookIvar<YTPivotBarItemView*>(self, "_itemView4").hidden = YES;
		if(hideLibraryTab) MSHookIvar<YTPivotBarItemView*>(self, "_itemView5").hidden = YES;
	}

	- (YTPivotBarItemView*)itemView2
	{
		return hideExploreTab ? 0 : %orig;
	}

	- (YTPivotBarItemView*)itemView3
	{
		return hideSubscriptionsTab ? 0 : %orig;
	}

	- (YTPivotBarItemView*)itemView4
	{
		return hideInboxTab ? 0 : %orig;
	}

	- (YTPivotBarItemView*)itemView5
	{
		return hideLibraryTab ? 0 : %orig;
	}

	%end

%end

// HIDE STORIES

%group hideStoriesGroup

	%hook YTReelShelfView

	- (double)preferredHeightForRenderer: (id)arg1
	{
		return 0;
	}

	%end

%end

// DISABLE HINTS

%group disableHintsGroup

	%hook YTSettings

	- (_Bool)areHintsDisabled
	{
		return YES;
	}

	- (void)setHintsDisabled:(_Bool)arg1
	{
		%orig(YES);
	}

	%end

	%hook YTUserDefaults

	- (_Bool)areHintsDisabled
	{
		return YES;
	}

	- (void)setHintsDisabled:(_Bool)arg1
	{
		%orig(YES);
	}

	%end

%end

// SHOW STATUS BAR ON LANDSCAPE

%group showStatusBarOnLandscapeGroup

	%hook YTSettings

	- (BOOL)showStatusBarWithOverlay
	{
		return YES;
	}

	%end

	%hook UIStatusBarManager

	- (BOOL)_updateVisibilityForWindow: (id)arg1 targetOrientation: (long long)arg2 animationParameters: (id*)arg3
	{
		return %orig(NULL, arg2, arg3);
	}

	%end

%end

%ctor
{
	@autoreleasepool
	{
		pref = [[HBPreferences alloc] initWithIdentifier: @"com.johnzaro.perfectyoutubeprefs"];
		[pref registerDefaults:
		@{
			@"backgroundPlayback": @NO,
			@"disableInVideoAds": @NO,
			@"hideDownloadButton": @NO,
			@"hideCastButton": @NO,
			@"hideVoiceSearchButton": @NO,
			@"disableHints": @NO,
			@"allowHDOnCellular": @NO,
			@"hideStories": @NO,
			@"noPopupsOnVideoEnd": @NO,
			@"hideDarkBackgroundOverlayInVideo": @NO,
			@"showProgressBarInVideo": @NO,
			@"hideComments": @NO,
			@"hideExploreTab": @NO,
			@"hideSubscriptionsTab": @NO,
			@"hideInboxTab": @NO,
			@"hideLibraryTab": @NO,
			@"showStatusBarOnLandscape": @NO,
    	}];

		backgroundPlayback = [pref boolForKey: @"backgroundPlayback"];
		disableInVideoAds = [pref boolForKey: @"disableInVideoAds"];
		hideDownloadButton = [pref boolForKey: @"hideDownloadButton"];
		hideCreateVideoButton = [pref boolForKey: @"hideCreateVideoButton"];
		hideCastButton = [pref boolForKey: @"hideCastButton"];
		hideVoiceSearchButton = [pref boolForKey: @"hideVoiceSearchButton"];
		disableHints = [pref boolForKey: @"disableHints"];
		allowHDOnCellular = [pref boolForKey: @"allowHDOnCellular"];
		hideStories = [pref boolForKey: @"hideStories"];
		noPopupsOnVideoEnd = [pref boolForKey: @"noPopupsOnVideoEnd"];
		hideDarkBackgroundOverlayInVideo = [pref boolForKey: @"hideDarkBackgroundOverlayInVideo"];
		showProgressBarInVideo = [pref boolForKey: @"showProgressBarInVideo"];
		hideComments = [pref boolForKey: @"hideComments"];
		hideExploreTab = [pref boolForKey: @"hideExploreTab"];
		hideSubscriptionsTab = [pref boolForKey: @"hideSubscriptionsTab"];
		hideInboxTab = [pref boolForKey: @"hideInboxTab"];
		hideLibraryTab = [pref boolForKey: @"hideLibraryTab"];
		showStatusBarOnLandscape = [pref boolForKey: @"showStatusBarOnLandscape"];

        if(backgroundPlayback) %init(backgroundPlaybackGroup);
        if(disableInVideoAds) %init(disableInVideoAdsGroup);
        if(hideDownloadButton) %init(hideDownloadButtonGroup);
        if(hideCreateVideoButton) %init(hideCreateVideoButtonGroup);
        if(hideCastButton) %init(hideCastButtonGroup);
        if(hideVoiceSearchButton) %init(hideVoiceSearchButtonGroup);
        if(disableHints) %init(disableHintsGroup);
        if(allowHDOnCellular) %init(allowHDOnCellularGroup);
        if(hideStories) %init(hideStoriesGroup);
        if(noPopupsOnVideoEnd) %init(noPopupsOnVideoEndGroup);
        if(hideDarkBackgroundOverlayInVideo) %init(hideDarkBackgroundOverlayInVideoGroup);
        if(showProgressBarInVideo) %init(showProgressBarInVideoGroup);
        if(hideComments) %init(hideCommentsGroup);
        if(hideExploreTab || hideSubscriptionsTab || hideInboxTab || hideLibraryTab) %init(hideTabGroup);
		if(showStatusBarOnLandscape) %init(showStatusBarOnLandscapeGroup);
    }
}
