@interface SBUIController
+ (id)sharedInstance;
- (BOOL)isBatteryCharging;
@end

@interface SBCoverSheetPresentationManager
+ (id)sharedInstance;
- (BOOL)_isEffectivelyLocked;
- (BOOL)hasBeenDismissedSinceKeybagLock;
@end