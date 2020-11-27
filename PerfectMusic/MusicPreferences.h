#import <Cephei/HBPreferences.h>

@interface MusicPreferences: NSObject
{
	HBPreferences *_preferences;
}
@property(nonatomic, readonly) BOOL enabled;

@property(nonatomic, readonly) BOOL enabledMediaControlWithVolumeButtons;
@property(nonatomic, readonly) BOOL swapVolumeButtonsBasedOnOrientation;
@property(nonatomic, readonly) BOOL pauseMusicOnZeroVolume;

@property(nonatomic, readonly) BOOL showNotificationOnSongChange;
@property(nonatomic, readonly) BOOL vibrateOnSongChange;

@property(nonatomic, readonly) BOOL lockscreenMusicWidgetTransparentBackground;
@property(nonatomic, readonly) BOOL vibrateMusicWidget;

@property(nonatomic, readonly) BOOL addExtraButtonsToLockScreen;
@property(nonatomic, readonly) BOOL addExtraButtonsToControlCenter;

@property(nonatomic, readonly) NSInteger lockScreenMusicWidgetStyle;
@property(nonatomic, readonly) NSInteger lockScreenMusicWidgetCompactStyle;

@property(nonatomic, readonly) BOOL lockScreenMusicWidgetHideAlbumArtwork;
@property(nonatomic, readonly) BOOL lockScreenMusicWidgetHideRoutingButton;

@property(nonatomic, readonly) BOOL enableLockScreenMusicWidgetDynamicColors;
@property(nonatomic, readonly) BOOL addLockScreenMusicWidgetBorderDynamicColor;
@property(nonatomic, readonly) CGFloat lockScreenMusicWidgetBackgroundColorAlpha;
@property(nonatomic, readonly) CGFloat lockScreenMusicWidgetBorderColorAlpha;
@property(nonatomic, readonly) NSInteger lockScreenMusicWidgetBorderWidth;

@property(nonatomic, readonly) NSInteger lockScreenAlbumArtworkCornerRadius;
@property(nonatomic, readonly) NSInteger lockScreenMusicWidgetCornerRadius;
@property(nonatomic, readonly) BOOL disableTopLeftCornerRadius;
@property(nonatomic, readonly) BOOL disableTopRightCornerRadius;
@property(nonatomic, readonly) BOOL disableBottomLeftCornerRadius;
@property(nonatomic, readonly) BOOL disableBottomRightCornerRadius;

@property(nonatomic, readonly) BOOL enableControlCenterMusicWidgetDynamicColors;
@property(nonatomic, readonly) BOOL addControlCenterWidgetBorder;
@property(nonatomic, readonly) CGFloat controlCenterMusicWidgetBackgroundColorAlpha;
@property(nonatomic, readonly) CGFloat controlCenterMusicWidgetBorderColorAlpha;

@property(nonatomic, readonly) BOOL enableMusicAppCustomRecentlyAddedColumnsNumber;
@property(nonatomic, readonly) NSInteger musicAppCustomRecentlyAddedColumnsNumber;
@property(nonatomic, readonly) BOOL musicAppHideKeepOrClearAlert;
@property(nonatomic, readonly) NSInteger musicAppKeepOrClearAlertAction;
@property(nonatomic, readonly) BOOL musicAppHideQueueHUD;
@property(nonatomic, readonly) BOOL musicAppHideCellSeparators;
@property(nonatomic, readonly) BOOL _200RecentAlbums;
@property(nonatomic, readonly) BOOL musicAppHideForYouAndBrowseTabs;
@property(nonatomic, readonly) BOOL musicAppHideRadioTab;
@property(nonatomic, readonly) BOOL vibrateMusicApp;

@property(nonatomic, readonly) BOOL enableMusicAppCustomTintColor;
@property(nonatomic, readonly) UIColor *musicAppCustomTintColor;

@property(nonatomic, readonly) BOOL musicAppNowPlayingViewHideGrabber;
@property(nonatomic, readonly) BOOL hideMusicAppNowPlayingViewAlbumShadow;

@property(nonatomic, readonly) NSInteger musicAppNowPlayingViewColorsStyle;

@property(nonatomic, readonly) BOOL enableMusicAppNowPlayingViewDynamicColors;
@property(nonatomic, readonly) BOOL musicAppNowPlayingViewBackgroundDynamicColor;
@property(nonatomic, readonly) BOOL addMusicAppNowPlayingViewBorderDynamicColor;
@property(nonatomic, readonly) BOOL enableMusicAppQueueViewDynamicColors;
@property(nonatomic, readonly) BOOL enableMusicAppMiniPlayerViewDynamicColors;

@property(nonatomic, readonly) BOOL enableMusicAppNowPlayingViewBackgroundStaticColor;
@property(nonatomic, readonly) UIColor *customMusicAppNowPlayingViewBackgroundColor;
@property(nonatomic, readonly) BOOL enableMusicAppNowPlayingViewBorderStaticColor;
@property(nonatomic, readonly) UIColor *customMusicAppNowPlayingViewBorderColor;
@property(nonatomic, readonly) BOOL enableMusicAppNowPlayingViewButtonsStaticColor;
@property(nonatomic, readonly) UIColor *customMusicAppNowPlayingViewButtonsColor;
@property(nonatomic, readonly) BOOL enableMusicAppNowPlayingViewTimeControlsStaticColor;
@property(nonatomic, readonly) UIColor *customMusicAppNowPlayingViewTimeControlsColor;
@property(nonatomic, readonly) BOOL enableMusicAppNowPlayingViewVolumeControlsStaticColor;
@property(nonatomic, readonly) UIColor *customMusicAppNowPlayingViewVolumeControlsColor;

@property(nonatomic, readonly) NSInteger musicAppNowPlayingViewBorderWidth;

@property(nonatomic, readonly) BOOL isIpad;

+ (id)sharedInstance;
@end
