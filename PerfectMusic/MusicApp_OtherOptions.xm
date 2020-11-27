#import "MusicApp.h"
#import "MusicPreferences.h"

static MusicPreferences *preferences;

static CGFloat screenWidth;
static NSInteger musicAppCustomRecentlyAddedColumnsNumber;

static void produceLightVibration()
{
	UIImpactFeedbackGenerator *gen = [[UIImpactFeedbackGenerator alloc] initWithStyle: UIImpactFeedbackStyleLight];
	[gen prepare];
	[gen impactOccurred];
}

// -------------------------------------- SET 3 COLUMNS ALBUMS - IPHONE ONLY  ------------------------------------------------

%group musicAppCustomRecentlyAddedColumnsNumberGroup

	static CGSize albumSize;
	static BOOL isAlbumSizeSet = NO;

	%hook UICollectionViewFlowLayout

	- (void)setItemSize: (CGSize)arg
	{
		if(!isAlbumSizeSet)
		{
			if(musicAppCustomRecentlyAddedColumnsNumber == 3)
				albumSize = CGSizeMake(screenWidth / 3.8, arg.height * 0.63);
			else if(musicAppCustomRecentlyAddedColumnsNumber == 4)
				albumSize = CGSizeMake(screenWidth / 5.2, arg.height * 0.55);
			else if(musicAppCustomRecentlyAddedColumnsNumber == 5)
				albumSize = CGSizeMake(screenWidth / 6.5, arg.height * 0.48);
			
			isAlbumSizeSet = YES;
		}
		
		%orig(albumSize);
	}

	%end

%end

// -------------------------------------- NO QUEUE HUD  ------------------------------------------------

// Original tweak by @nahtedetihw: https://github.com/nahtedetihw/MusicQueueBeGone

%group musicAppHideQueueHUDGroup

	%hook ContextActionsHUDViewController

	- (void)viewDidLoad
	{

	}
		
	%end

%end

// -------------------------------------- ALWAYS KEEP OR CLEAR QUEUE --------------------------------------

%group musicAppHideKeepOrClearAlertGroup

	// Original tweak by @arandomdev: https://github.com/arandomdev/AlwaysClear

	%hook MusicApplicationTabController

	- (void)presentViewController: (UIViewController*)viewControllerToPresent animated: (BOOL)flag completion: (void (^)(void))completion
	{
		if([viewControllerToPresent isKindOfClass: [UIAlertController class]])
		{
			UIAlertController *alertController = (UIAlertController*)viewControllerToPresent;
			if([[alertController message] containsString: @"playing"] && [[alertController message] containsString: @"queue"])
			{
				UIAlertAction *clearAction = alertController.actions[[preferences musicAppKeepOrClearAlertAction]];
				clearAction.handler(clearAction);
				
				if(completion)
					completion();
			}
		}
		else 
			%orig;
	}

	%end

%end

// -------------------------------------- HIDE SEPARATOR --------------------------------------

%group musicAppHideCellSeparatorsGroup

	%hook UITableViewCell

	- (void)_updateSeparatorContent
	{

	}

	%end

%end

// -------------------------------------- 200 RECENT ALBUMS --------------------------------------

%group _200RecentAlbumsGroup

	%hook MPModelLibraryRequest

	- (void)setContentRange: (NSRange)range
	{
		range.length = 200;
		%orig;
	}

	%end

%end

// -------------------------------------- HIDE NOW PLAYING VIEW'S GRABBER --------------------------------------

%group musicAppNowPlayingViewHideGrabberGroup

	%hook MusicNowPlayingControlsViewController

	- (void)viewDidLayoutSubviews
	{
		%orig;

		[MSHookIvar<UIView*>(self, "grabberView") setHidden: YES];
	}

	%end

%end

// -------------------------------------- HIDE ALBUM SHADOW --------------------------------------

%group hideMusicAppNowPlayingViewAlbumShadowGroup

	%hook NowPlayingContentView

	- (void)layoutSubviews
	{
		%orig;

		[[self layer] setShadowOpacity: 0];
	}

	%end

%end

// -------------------------------------- VIBRATIONS ------------------------------------------------

%group vibrateMusicAppGroup

	%hook  UITableViewCell

	- (void)touchesBegan: (id)arg1 withEvent: (id)arg2
	{
		produceLightVibration();
		%orig;
	}

	%end

	%hook UICollectionViewCell

	- (void)touchesBegan: (id)arg1 withEvent: (id)arg2
	{
		produceLightVibration();
		%orig;
	}

	%end

	%hook UITabBarButton

	- (void)touchesBegan: (id)arg1 withEvent: (id)arg2
	{
		produceLightVibration();
		%orig;
	}

	%end

	%hook UIButton

	- (void)touchesBegan: (id)arg1 withEvent: (id)arg2
	{
		produceLightVibration();
		%orig;
	}

	%end

	%hook MPRouteButton

	- (void)touchesBegan: (id)arg1 withEvent: (id)arg2
	{
		produceLightVibration();
		%orig;
	}

	%end

	%hook UISegmentedControl

	- (void)touchesBegan: (id)arg1 withEvent: (id)arg2
	{
		produceLightVibration();
		%orig;
	}

	%end

	%hook UITextField

	- (void)touchesBegan: (id)arg1 withEvent: (id)arg2
	{
		produceLightVibration();
		%orig;
	}

	%end

	%hook _UIButtonBarButton

	- (void)touchesBegan: (id)arg1 withEvent: (id)arg2
	{
		produceLightVibration();
		%orig;
	}

	%end

	%hook TimeSlider

	- (void)touchesBegan: (id)arg1 withEvent: (id)arg2
	{
		produceLightVibration();
		%orig;
	}

	%end

	%hook MPVolumeSlider

	- (void)touchesBegan: (id)arg1 withEvent: (id)arg2
	{
		produceLightVibration();
		%orig;
	}

	%end

%end

// -------------------------------------- HIDE 'FOR YOU' AND 'BROWSE' TAB ------------------------------------------------

%group musicAppHideForYouAndBrowseTabsGroup

	%hook MPCloudServiceStatusController

	- (BOOL)isSubscriptionAvailable
	{
		return NO;
	}

	%end

%end

// -------------------------------------- HIDE RADIO TAB ------------------------------------------------

%group musicAppHideRadioTabGroup

	%hook RadioAvailabilityController

	- (BOOL)isRadioAvailable
	{
		return NO;
	}

	%end

%end

void initMusicApp_OtherOptions()
{
	preferences = [MusicPreferences sharedInstance];

	if([preferences enableMusicAppCustomRecentlyAddedColumnsNumber] && ![preferences isIpad])
	{
		screenWidth = [[UIScreen mainScreen] _referenceBounds].size.width;
		musicAppCustomRecentlyAddedColumnsNumber = [preferences musicAppCustomRecentlyAddedColumnsNumber];
		%init(musicAppCustomRecentlyAddedColumnsNumberGroup);
	}

	if([preferences musicAppHideQueueHUD]) 
		%init(musicAppHideQueueHUDGroup, ContextActionsHUDViewController = NSClassFromString(@"MusicApplication.ContextActionsHUDViewController"));

	if([preferences musicAppHideKeepOrClearAlert])
		%init(musicAppHideKeepOrClearAlertGroup, MusicApplicationTabController = NSClassFromString(@"MusicApplication.TabBarController"));

	if([preferences musicAppHideCellSeparators])
		%init(musicAppHideCellSeparatorsGroup);

	if([preferences _200RecentAlbums])
		%init(_200RecentAlbumsGroup);

	if([preferences musicAppNowPlayingViewHideGrabber])
		%init(musicAppNowPlayingViewHideGrabberGroup);

	if([preferences hideMusicAppNowPlayingViewAlbumShadow])
		%init(hideMusicAppNowPlayingViewAlbumShadowGroup, NowPlayingContentView = NSClassFromString(@"MusicApplication.NowPlayingContentView"));

	if([preferences vibrateMusicApp] && ![preferences isIpad]) 
		%init(vibrateMusicAppGroup, TimeSlider = NSClassFromString(@"MusicApplication.PlayerTimeControl"));

	if([preferences musicAppHideForYouAndBrowseTabs])
		%init(musicAppHideForYouAndBrowseTabsGroup);

	if([preferences musicAppHideRadioTab])
		%init(musicAppHideRadioTabGroup);
}