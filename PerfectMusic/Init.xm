#import "MusicPreferences.h"

extern void initVolumeControl();

extern void initMediaNotification();

extern void initExtraButtons();

extern void initCompactMediaPlayer();

extern void initMusicWidgetHelper();
extern void initMusicWidget_DynamicColors();
extern void initMusicWidget_OtherOptions();

extern void initMusicAppHelper();
extern void initMusicApp_OtherOptions();
extern void initMusicApp_DynamicColors();
extern void initMusicApp_StaticColors();

static MusicPreferences *preferences;

%ctor
{
    preferences = [MusicPreferences sharedInstance];
    if([preferences enabled])
    {
        NSString *processName = [NSProcessInfo processInfo].processName;
        bool isSpringboard = [@"SpringBoard" isEqualToString: processName];
        bool isMusicApp = [@"Music" isEqualToString: processName];

        if(isSpringboard) 
        {
            initMusicWidgetHelper();

            if([preferences enabledMediaControlWithVolumeButtons] 
            || [preferences swapVolumeButtonsBasedOnOrientation] 
            || [preferences pauseMusicOnZeroVolume])
                initVolumeControl();

            if([preferences showNotificationOnSongChange] || [preferences vibrateOnSongChange])
                initMediaNotification();

            if([preferences addExtraButtonsToLockScreen] || [preferences addExtraButtonsToControlCenter])
                initExtraButtons();

            if([preferences lockScreenMusicWidgetStyle] == 1)
                initCompactMediaPlayer();
            
            initMusicWidget_DynamicColors();
            initMusicWidget_OtherOptions();
        }
        else if(isMusicApp)
        {
            initMusicAppHelper();

            initMusicApp_OtherOptions();

            if([preferences musicAppNowPlayingViewColorsStyle] == 1)
                initMusicApp_DynamicColors();
            
            initMusicApp_StaticColors();

        }
    }
}