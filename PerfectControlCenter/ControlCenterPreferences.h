#import <Cephei/HBPreferences.h>

@interface ControlCenterPreferences: NSObject
{
	HBPreferences *_preferences;
}
@property(nonatomic, readonly) BOOL enabled;
@property(nonatomic, readonly) BOOL roundCCModules;
@property(nonatomic, readonly) BOOL showSliderPercentage;
@property(nonatomic, readonly) BOOL hideControlCenterStatusBar;
@property(nonatomic, readonly) BOOL moveControlCenterToTheBottom;

@property(nonatomic, readonly) BOOL turnOffOnTap;
@property(nonatomic, readonly) BOOL customConnectivitySizeEnabled;
@property(nonatomic, readonly) NSInteger connectivityRows;
@property(nonatomic, readonly) NSInteger connectivityColumns;
@property(nonatomic, readonly) BOOL customMusicSizeEnabled;
@property(nonatomic, readonly) NSInteger musicSize;

@property(nonatomic, readonly) BOOL respringConfirmation;
@property(nonatomic, readonly) BOOL ldRestartConfirmation;
@property(nonatomic, readonly) BOOL safeModeConfirmation;
@property(nonatomic, readonly) BOOL uiCacheConfirmation;
@property(nonatomic, readonly) BOOL powerOffConfirmation;
@property(nonatomic, readonly) BOOL rebootConfirmation;

@property(nonatomic, readonly) BOOL isIpad;

+ (id)sharedInstance;
@end
