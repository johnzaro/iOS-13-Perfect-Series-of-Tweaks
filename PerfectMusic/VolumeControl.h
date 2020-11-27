@interface SBApplication: NSObject
- (NSString*)bundleIdentifier;
@end

@interface SpringBoard: UIApplication
- (SBApplication*)_accessibilityFrontMostApplication;
- (void)invalidateForward;
- (void)invalidateBack;
@end

@interface SBVolumeControl
- (float)_effectiveVolume;
- (void)changeVolumeByDelta: (float)arg1;
@end

@interface SBMediaPlayer: NSObject
+ (id)sharedInstance;
- (BOOL)isPaused;
- (BOOL)playForEventSource: (long long)arg1;
- (BOOL)pauseForEventSource: (long long)arg1;
@end