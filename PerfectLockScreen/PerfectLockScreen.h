@interface SBUIBiometricResource: NSObject
+ (id)sharedInstance;
- (void)noteScreenDidTurnOff;
- (void)noteScreenWillTurnOn;
@end

@interface MRPlatterViewController: UIViewController
@end

@interface SBUIFlashlightController: NSObject
+ (id)sharedInstance;
- (NSInteger)level;
@end

@interface SBCoverSheetPanelBackgroundContainerView: UIView
- (void)_setCornerRadius: (double)arg1;
@end

@interface UIScreen ()
- (double)_displayCornerRadius;
@end

@interface CSQuickActionsButton: UIControl
- (long long)type;
@end

@interface SBFLockScreenDateView: UIView
@property(nonatomic, retain) UIImageView *dndImageView;
@property(nonatomic, retain) UIImageView *silentImageView;
- (id)initWithFrame: (CGRect)arg1;
- (void)layoutSubviews;
- (void)updateIndicatorImageView;
@end

@interface UIApplication ()
- (BOOL)launchApplicationWithIdentifier: (id)arg1 suspended: (BOOL)arg2;
@end

@interface CSMainPageContentViewController: UIViewController
- (BOOL)_listBelowDateTime;
@end

@interface CSCoverSheetViewController: UIViewController
- (CSMainPageContentViewController*)mainPageContentViewController;
@end

@interface SBLockScreenManager: NSObject
- (CSCoverSheetViewController*)coverSheetViewController;
+ (id)sharedInstance;
- (BOOL)unlockUIFromSource: (int)arg1 withOptions: (id)arg2;
- (id)averageColorForCurrentWallpaperInScreenRect: (CGRect)arg1;
@end

@interface UIScreen ()
@property(nonatomic, readonly) CGRect _referenceBounds;
@end

@interface UIApplication ()
- (UIDeviceOrientation)_frontMostAppOrientation;
@end

@interface UICoverSheetButton: UIControl
- (void)setEdgeInsets: (UIEdgeInsets)arg1;
- (NSString*)localizedAccessoryTitle;
@end

@interface SBFTouchPassThroughView: UIView
@property(nonatomic, retain) UICoverSheetButton *flashlightButton;
@property(nonatomic, retain) UICoverSheetButton *cameraButton;
- (UIEdgeInsets)_buttonOutsets;
- (void)_layoutQuickActionButtons;
- (void)handleButtonPress:(id)arg1;
@end

@interface CSQuickActionsView: SBFTouchPassThroughView
@end

@interface SBUIProudLockIconView: UIView
@end

