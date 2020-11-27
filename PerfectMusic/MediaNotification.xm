#import "MusicPreferences.h"
#import "MediaRemote.h"
#import "MediaNotification.h"
#import <dlfcn.h>

static MusicPreferences *preferences;

static BBServer *bbServer = nil;

static NSDictionary *dict;
static NSString *cachedTitle;
static NSString *artist;
static NSString *album;

static BOOL notificationEnabled;
static BOOL vibrationEnabled;

static void produceMediumVibration()
{
	UIImpactFeedbackGenerator *gen = [[UIImpactFeedbackGenerator alloc] initWithStyle: UIImpactFeedbackStyleMedium];
	[gen prepare];
	[gen impactOccurred];
}

static dispatch_queue_t getBBServerQueue()
{
	static dispatch_queue_t queue;
	static dispatch_once_t predicate;
	dispatch_once(&predicate,
	^{
		void *handle = dlopen(NULL, RTLD_GLOBAL);
		if(handle)
		{
			dispatch_queue_t __weak *pointer = (__weak dispatch_queue_t *) dlsym(handle, "__BBServerQueue");
			if(pointer) queue = *pointer;
			dlclose(handle);        
		}
	});
	return queue;
}

%group notificationOrVibrationGroup

	%hook SBMediaController

	- (void)setNowPlayingInfo: (id)arg1
	{
		%orig;

		MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef information) { dict = (__bridge NSDictionary *)information; });

		NSString *newTitle = [dict objectForKey: (__bridge NSString*)kMRMediaRemoteNowPlayingInfoTitle];
		if(newTitle && ![newTitle isEqualToString: cachedTitle] && [self isPlaying])
		{
			cachedTitle = newTitle;
			
			if(notificationEnabled && ![[%c(SBCoverSheetPresentationManager) sharedInstance] isPresented])
			{
				NSString *newArtist = [dict objectForKey: (__bridge NSString*)kMRMediaRemoteNowPlayingInfoArtist];

				BBBulletin *bulletin = [[%c(BBBulletin) alloc] init];
				[bulletin setTitle: @"Now Playing"];
				[bulletin setMessage: [NSString stringWithFormat: @"%@\n%@", newTitle, newArtist]];
				[bulletin setSectionID: [[self nowPlayingApplication] bundleIdentifier]];
				[bulletin setBulletinID: [[NSProcessInfo processInfo] globallyUniqueString]];
				[bulletin setRecordID: [[NSProcessInfo processInfo] globallyUniqueString]];
				[bulletin setPublisherBulletinID: [[NSProcessInfo processInfo] globallyUniqueString]];
				[bulletin setDate: [NSDate date]];
				[bulletin setDefaultAction: [%c(BBAction) actionWithLaunchBundleID: [bulletin sectionID] callblock: nil]];

				if(bbServer && [bbServer respondsToSelector: @selector(publishBulletin:destinations:)])
				{
					dispatch_sync(getBBServerQueue(), 
					^{
						[bbServer publishBulletin: bulletin destinations: 8];
					});
				}
			}

			if(vibrationEnabled)
				produceMediumVibration();
		}
	}

	%end

%end

%group initBBServerGroup

	%hook BBServer

	- (id)initWithQueue: (id)arg1
	{
		bbServer = %orig;
		return bbServer;
	}

	- (id)initWithQueue: (id)arg1 dataProviderManager: (id)arg2 syncService: (id)arg3 dismissalSyncCache: (id)arg4 observerListener: (id)arg5 utilitiesListener: (id)arg6 conduitListener: (id)arg7 systemStateListener: (id)arg8 settingsListener: (id)arg9
	{
		bbServer = %orig;
		return bbServer;
	}

	- (void)dealloc
	{
		if (bbServer == self) bbServer = nil;
		%orig;
	}

	%end

%end

void initMediaNotification()
{
	preferences = [MusicPreferences sharedInstance];

	notificationEnabled = [preferences showNotificationOnSongChange];
	vibrationEnabled = [preferences vibrateOnSongChange];

	if(notificationEnabled)
		%init(initBBServerGroup);

	if(notificationEnabled || vibrationEnabled)
		%init(notificationOrVibrationGroup);
}