#import "MusicPreferences.h"
#import "SparkColourPickerUtils.h"

#define IS_iPAD ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

@implementation MusicPreferences

+ (instancetype)sharedInstance
{
	static MusicPreferences *sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, 
	^{
		sharedInstance = [[MusicPreferences alloc] init];
	});
	return sharedInstance;
}

- (id)init
{
	self = [super init];

	_preferences = [[HBPreferences alloc] initWithIdentifier: @"com.johnzaro.perfectmusicprefs"];
	[_preferences registerBool: &_enabled default: NO forKey: @"enabled"];
	if(_enabled)
	{
		NSDictionary *preferencesDictionary = [NSDictionary dictionaryWithContentsOfFile: @"/var/mobile/Library/Preferences/com.johnzaro.perfectmusicprefs.colors.plist"];

		[_preferences registerBool: &_enabledMediaControlWithVolumeButtons default: NO forKey: @"enabledMediaControlWithVolumeButtons"];
		[_preferences registerBool: &_swapVolumeButtonsBasedOnOrientation default: NO forKey: @"swapVolumeButtonsBasedOnOrientation"];
		[_preferences registerBool: &_pauseMusicOnZeroVolume default: NO forKey: @"pauseMusicOnZeroVolume"];
		
		[_preferences registerBool: &_showNotificationOnSongChange default: NO forKey: @"showNotificationOnSongChange"];
		[_preferences registerBool: &_vibrateOnSongChange default: NO forKey: @"vibrateOnSongChange"];

		[_preferences registerBool: &_lockscreenMusicWidgetTransparentBackground default: NO forKey: @"lockscreenMusicWidgetTransparentBackground"];
		[_preferences registerBool: &_vibrateMusicWidget default: NO forKey: @"vibrateMusicWidget"];

		[_preferences registerBool: &_addExtraButtonsToLockScreen default: NO forKey: @"addExtraButtonsToLockScreen"];
		[_preferences registerBool: &_addExtraButtonsToControlCenter default: NO forKey: @"addExtraButtonsToControlCenter"];
		
		[_preferences registerInteger: &_lockScreenMusicWidgetStyle default: 0 forKey: @"lockScreenMusicWidgetStyle"];
		[_preferences registerInteger: &_lockScreenMusicWidgetCompactStyle default: 0 forKey: @"lockScreenMusicWidgetCompactStyle"];

		[_preferences registerBool: &_lockScreenMusicWidgetHideAlbumArtwork default: NO forKey: @"lockScreenMusicWidgetHideAlbumArtwork"];
		[_preferences registerBool: &_lockScreenMusicWidgetHideRoutingButton default: NO forKey: @"lockScreenMusicWidgetHideRoutingButton"];

		[_preferences registerBool: &_enableLockScreenMusicWidgetDynamicColors default: NO forKey: @"enableLockScreenMusicWidgetDynamicColors"];
		[_preferences registerBool: &_addLockScreenMusicWidgetBorderDynamicColor default: NO forKey: @"addLockScreenMusicWidgetBorderDynamicColor"];
		[_preferences registerDouble: &_lockScreenMusicWidgetBackgroundColorAlpha default: 1 forKey: @"lockScreenMusicWidgetBackgroundColorAlpha"];
		[_preferences registerDouble: &_lockScreenMusicWidgetBorderColorAlpha default: 1 forKey: @"lockScreenMusicWidgetBorderColorAlpha"];
		[_preferences registerInteger: &_lockScreenMusicWidgetBorderWidth default: 3 forKey: @"lockScreenMusicWidgetBorderWidth"];

		[_preferences registerInteger: &_lockScreenAlbumArtworkCornerRadius default: 4 forKey: @"lockScreenAlbumArtworkCornerRadius"];
		[_preferences registerInteger: &_lockScreenMusicWidgetCornerRadius default: 13 forKey: @"lockScreenMusicWidgetCornerRadius"];
		[_preferences registerBool: &_disableTopLeftCornerRadius default: NO forKey: @"disableTopLeftCornerRadius"];
		[_preferences registerBool: &_disableTopRightCornerRadius default: NO forKey: @"disableTopRightCornerRadius"];
		[_preferences registerBool: &_disableBottomLeftCornerRadius default: NO forKey: @"disableBottomLeftCornerRadius"];
		[_preferences registerBool: &_disableBottomRightCornerRadius default: NO forKey: @"disableBottomRightCornerRadius"];

		[_preferences registerBool: &_enableControlCenterMusicWidgetDynamicColors default: NO forKey: @"enableControlCenterMusicWidgetDynamicColors"];
		[_preferences registerBool: &_addControlCenterWidgetBorder default: NO forKey: @"addControlCenterWidgetBorder"];
		[_preferences registerDouble: &_controlCenterMusicWidgetBackgroundColorAlpha default: 1 forKey: @"controlCenterMusicWidgetBackgroundColorAlpha"];
		[_preferences registerDouble: &_controlCenterMusicWidgetBorderColorAlpha default: 1 forKey: @"controlCenterMusicWidgetBorderColorAlpha"];
		
		[_preferences registerBool: &_enableMusicAppCustomRecentlyAddedColumnsNumber default: NO forKey: @"enableMusicAppCustomRecentlyAddedColumnsNumber"];
		[_preferences registerInteger: &_musicAppCustomRecentlyAddedColumnsNumber default: 3 forKey: @"musicAppCustomRecentlyAddedColumnsNumber"];
		[_preferences registerBool: &_musicAppHideKeepOrClearAlert default: NO forKey: @"musicAppHideKeepOrClearAlert"];
		[_preferences registerInteger: &_musicAppKeepOrClearAlertAction default: 1 forKey: @"musicAppKeepOrClearAlertAction"];
		[_preferences registerBool: &_musicAppHideQueueHUD default: NO forKey: @"musicAppHideQueueHUD"];
		[_preferences registerBool: &_musicAppHideCellSeparators default: NO forKey: @"musicAppHideCellSeparators"];
		[_preferences registerBool: &__200RecentAlbums default: NO forKey: @"_200RecentAlbums"];
		[_preferences registerBool: &_musicAppHideForYouAndBrowseTabs default: NO forKey: @"musicAppHideForYouAndBrowseTabs"];
		[_preferences registerBool: &_musicAppHideRadioTab default: NO forKey: @"musicAppHideRadioTab"];
		[_preferences registerBool: &_vibrateMusicApp default: NO forKey: @"vibrateMusicApp"];

		[_preferences registerBool: &_enableMusicAppCustomTintColor default: NO forKey: @"enableMusicAppCustomTintColor"];
		_musicAppCustomTintColor = [SparkColourPickerUtils colourWithString: [preferencesDictionary objectForKey: @"musicAppCustomTintColor"] withFallback: @"#FF9400"];

		[_preferences registerBool: &_musicAppNowPlayingViewHideGrabber default: NO forKey: @"musicAppNowPlayingViewHideGrabber"];
		[_preferences registerBool: &_hideMusicAppNowPlayingViewAlbumShadow default: NO forKey: @"hideMusicAppNowPlayingViewAlbumShadow"];

		[_preferences registerInteger: &_musicAppNowPlayingViewColorsStyle default: 0 forKey: @"musicAppNowPlayingViewColorsStyle"];

		[_preferences registerBool: &_enableMusicAppNowPlayingViewDynamicColors default: NO forKey: @"enableMusicAppNowPlayingViewDynamicColors"];
		[_preferences registerBool: &_musicAppNowPlayingViewBackgroundDynamicColor default: NO forKey: @"musicAppNowPlayingViewBackgroundDynamicColor"];
		[_preferences registerBool: &_addMusicAppNowPlayingViewBorderDynamicColor default: NO forKey: @"addMusicAppNowPlayingViewBorderDynamicColor"];
		[_preferences registerBool: &_enableMusicAppQueueViewDynamicColors default: NO forKey: @"enableMusicAppQueueViewDynamicColors"];
		[_preferences registerBool: &_enableMusicAppMiniPlayerViewDynamicColors default: NO forKey: @"enableMusicAppMiniPlayerViewDynamicColors"];
		
		[_preferences registerBool: &_enableMusicAppNowPlayingViewBackgroundStaticColor default: NO forKey: @"enableMusicAppNowPlayingViewBackgroundStaticColor"];
		_customMusicAppNowPlayingViewBackgroundColor = [SparkColourPickerUtils colourWithString: [preferencesDictionary objectForKey: @"customMusicAppNowPlayingViewBackgroundColor"] withFallback: @"#FFFFFF"];
		[_preferences registerBool: &_enableMusicAppNowPlayingViewBorderStaticColor default: NO forKey: @"enableMusicAppNowPlayingViewBorderStaticColor"];
		_customMusicAppNowPlayingViewBorderColor = [SparkColourPickerUtils colourWithString: [preferencesDictionary objectForKey: @"customMusicAppNowPlayingViewBorderColor"] withFallback: @"#FF9400"];
		[_preferences registerBool: &_enableMusicAppNowPlayingViewButtonsStaticColor default: NO forKey: @"enableMusicAppNowPlayingViewButtonsStaticColor"];
		_customMusicAppNowPlayingViewButtonsColor = [SparkColourPickerUtils colourWithString: [preferencesDictionary objectForKey: @"customMusicAppNowPlayingViewButtonsColor"] withFallback: @"#FF9400"];
		[_preferences registerBool: &_enableMusicAppNowPlayingViewTimeControlsStaticColor default: NO forKey: @"enableMusicAppNowPlayingViewTimeControlsStaticColor"];
		_customMusicAppNowPlayingViewTimeControlsColor = [SparkColourPickerUtils colourWithString: [preferencesDictionary objectForKey: @"customMusicAppNowPlayingViewTimeControlsColor"] withFallback: @"#FF9400"];
		[_preferences registerBool: &_enableMusicAppNowPlayingViewVolumeControlsStaticColor default: NO forKey: @"enableMusicAppNowPlayingViewVolumeControlsStaticColor"];
		_customMusicAppNowPlayingViewVolumeControlsColor = [SparkColourPickerUtils colourWithString: [preferencesDictionary objectForKey: @"customMusicAppNowPlayingViewVolumeControlsColor"] withFallback: @"#FF9400"];
		
		[_preferences registerInteger: &_musicAppNowPlayingViewBorderWidth default: 4 forKey: @"musicAppNowPlayingViewBorderWidth"];

		_isIpad = IS_iPAD;
	}

	return self;
}

@end