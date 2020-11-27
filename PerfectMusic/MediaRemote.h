/*
 * Media remote framework header.
 *
 * Copyright (c) 2013-2014 Cykey (David Murray)
 * All rights reserved.
 */

#ifndef MEDIAREMOTE_H_
#define MEDIAREMOTE_H_

#if __cplusplus
extern "C" {
#endif
    
    /*
     * These are used on the local notification center.
     */

    // Notifications

    /*
     * These are used on the local notification center.
     */

    extern CFStringRef kMRMediaRemoteNowPlayingInfoDidChangeNotification;
    extern CFStringRef kMRMediaRemoteNowPlayingPlaybackQueueDidChangeNotification;
    extern CFStringRef kMRMediaRemotePickableRoutesDidChangeNotification;
    extern CFStringRef kMRMediaRemoteNowPlayingApplicationDidChangeNotification;
    extern CFStringRef kMRMediaRemoteNowPlayingApplicationIsPlayingDidChangeNotification;
    extern CFStringRef kMRMediaRemoteRouteStatusDidChangeNotification;

    // Keys

    extern CFStringRef kMRMediaRemoteNowPlayingApplicationPIDUserInfoKey;
    extern CFStringRef kMRMediaRemoteNowPlayingApplicationIsPlayingUserInfoKey;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoAlbum;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoArtist;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoArtworkData;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoArtworkMIMEType;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoChapterNumber;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoComposer;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoDuration;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoElapsedTime;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoGenre;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoIsAdvertisement;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoIsBanned;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoIsInWishList;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoIsLiked;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoIsMusicApp;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoPlaybackRate;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoProhibitsSkip;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoQueueIndex;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoRadioStationIdentifier;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoRepeatMode;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoShuffleMode;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoStartTime;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoSupportsFastForward15Seconds;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoSupportsIsBanned;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoSupportsIsLiked;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoSupportsRewind15Seconds;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoTimestamp;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoTitle;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoTotalChapterCount;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoTotalDiscCount;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoTotalQueueCount;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoTotalTrackCount;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoTrackNumber;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoUniqueIdentifier;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoRadioStationIdentifier;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoRadioStationHash;
    extern CFStringRef kMRMediaRemoteOptionMediaType;
    extern CFStringRef kMRMediaRemoteOptionSourceID;
    extern CFStringRef kMRMediaRemoteOptionTrackID;
    extern CFStringRef kMRMediaRemoteOptionStationID;
    extern CFStringRef kMRMediaRemoteOptionStationHash;
    extern CFStringRef kMRMediaRemoteRouteDescriptionUserInfoKey;
    extern CFStringRef kMRMediaRemoteRouteStatusUserInfoKey;

    typedef NS_ENUM(NSInteger, MRCommand) {
        kMRPlay = 0,
        kMRPause = 1,
        kMRTogglePlayPause = 2,
        kMRStop = 3,
        kMRNextTrack = 4,
        kMRPreviousTrack = 5,
        kMRToggleShuffle = 6,
        kMRToggleRepeat = 7,
        kMRStartForwardSeek = 8,
        kMREndForwardSeek = 9,
        kMRStartBackwardSeek = 10,
        kMREndBackwardSeek = 11,
        kMRSkipFifteenSeconds = 17,
        kMRGoBackFifteenSeconds = 18,
        kMRLikeTrack = 21,
        kMRBanTrack = 22,
        kMRBookmarkTrack = 23,
    };

    typedef NS_ENUM(uint32_t, MRMediaRemoteCommand) {
        MRMediaRemoteCommandPlay,
        MRMediaRemoteCommandPause,
        MRMediaRemoteCommandTogglePlayPause,
        MRMediaRemoteCommandStop,
        MRMediaRemoteCommandNextTrack,
        MRMediaRemoteCommandPreviousTrack,
        MRMediaRemoteCommandAdvanceShuffleMode,
        MRMediaRemoteCommandAdvanceRepeatMode,
        MRMediaRemoteCommandBeginFastForward,
        MRMediaRemoteCommandEndFastForward,
        MRMediaRemoteCommandBeginRewind,
        MRMediaRemoteCommandEndRewind,
        MRMediaRemoteCommandRewind15Seconds,
        MRMediaRemoteCommandFastForward15Seconds,
        MRMediaRemoteCommandRewind30Seconds,
        MRMediaRemoteCommandFastForward30Seconds,
        MRMediaRemoteCommandToggleRecord,
        MRMediaRemoteCommandSkipForward,
        MRMediaRemoteCommandSkipBackward,
        MRMediaRemoteCommandChangePlaybackRate,
        MRMediaRemoteCommandRateTrack,
        MRMediaRemoteCommandLikeTrack,
        MRMediaRemoteCommandDislikeTrack,
        MRMediaRemoteCommandBookmarkTrack,
        MRMediaRemoteCommandSeekToPlaybackPosition,
        MRMediaRemoteCommandChangeRepeatMode,
        MRMediaRemoteCommandChangeShuffleMode,
        MRMediaRemoteCommandEnableLanguageOption,
        MRMediaRemoteCommandDisableLanguageOption
    };

    Boolean MRMediaRemoteSendCommand(MRCommand command, id userInfo);
    void MRMediaRemoteSetElapsedTime(NSTimeInterval elapsedTime);
    void MRMediaRemoteCopySupportedCommands(dispatch_queue_t queue, void(^block)(NSArray *));
    MRCommand MRMediaRemoteCommandInfoGetCommand(id commandInfo);
    Boolean MRMediaRemoteCommandInfoGetEnabled(id commandInfo);
    CFTypeRef MRMediaRemoteCommandInfoCopyValueForKey(id commandInfo, CFStringRef key);
    Boolean MRMediaRemoteSendCommand(MRCommand command, id userInfo);

    void MRMediaRemoteSetPlaybackSpeed(int speed);
    void MRMediaRemoteSetElapsedTime(double elapsedTime);

    void MRMediaRemoteSetNowPlayingApplicationOverrideEnabled(Boolean enabled);

    void MRMediaRemoteRegisterForNowPlayingNotifications(dispatch_queue_t queue);
    void MRMediaRemoteUnregisterForNowPlayingNotifications();

    void MRMediaRemoteBeginRouteDiscovery();
    void MRMediaRemoteEndRouteDiscovery();

    CFArrayRef MRMediaRemoteCopyPickableRoutes();

    typedef void (^MRMediaRemoteGetNowPlayingInfoCompletion)(CFDictionaryRef information);
    typedef void (^MRMediaRemoteGetNowPlayingApplicationPIDCompletion)(int PID);
    typedef void (^MRMediaRemoteGetNowPlayingApplicationIsPlayingCompletion)(Boolean isPlaying);

    void MRMediaRemoteGetNowPlayingApplicationPID(dispatch_queue_t queue, MRMediaRemoteGetNowPlayingApplicationPIDCompletion completion);
    void MRMediaRemoteGetNowPlayingInfo(dispatch_queue_t queue, MRMediaRemoteGetNowPlayingInfoCompletion completion);
    void MRMediaRemoteGetNowPlayingApplicationIsPlaying(dispatch_queue_t queue, MRMediaRemoteGetNowPlayingApplicationIsPlayingCompletion completion);

    void MRMediaRemoteKeepAlive();
    void MRMediaRemoteSetElapsedTime(double time);
    void MRMediaRemoteSetShuffleMode(int mode);
    void MRMediaRemoteSetRepeatMode(int mode);

    /*
    * The identifier can be obtained using MRMediaRemoteCopyPickableRoutes.
    * Use the 'RouteUID' or the 'RouteName' key.
     */

    int MRMediaRemoteSelectSourceWithID(CFStringRef identifier);
    void MRMediaRemoteSetPickedRouteWithPassword(CFStringRef route, CFStringRef password);

    CFArrayRef MRMediaRemoteCopyPickableRoutesForCategory(NSString *category);
    Boolean MRMediaRemotePickedRouteHasVolumeControl();
    void MRMediaRemoteSetCanBeNowPlayingApplication(Boolean can);
    void MRMediaRemoteSetNowPlayingInfo(CFDictionaryRef information);

#if __cplusplus
}
#endif

#endif /* MEDIAREMOTE_H_ */