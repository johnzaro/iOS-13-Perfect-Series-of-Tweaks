@interface BCBatteryDevice: NSObject
@property(nonatomic, readonly) UIImage *glyph;
- (long long)percentCharge;
- (BOOL)isBatterySaverModeActive;
- (BOOL)isCharging;
- (NSString*)identifier;
@end

@interface BCBatteryDeviceController: NSObject
+ (id)sharedInstance;
- (NSArray*)connectedDevices;
@end

@interface PerfectBTBatteryInfo: NSObject
{
    UIWindow *bluetoothBatteryInfoWindow;
    UIImageView *glyphImageView;
    UILabel *percentageLabel;
    UILabel *deviceNameLabel;
    BCBatteryDevice *currentDevice;
    NSString *currentDeviceIdentifier;
    UIColor *backupForegroundColor;
    UIColor *backupBackgroundColor;
}
- (id)init;
- (void)updateWindowFrameWithAnimation: (BOOL)animation;
- (void)calculateNewWindowSize;
- (void)updateLabelsFrame;
- (void)updateGlyphFrame;
- (void)updateLabelsFont;
- (void)updatePercentage;
- (void)updatePercentageColor;
- (void)updateObjectWithNewSettings;
- (void)updateTextColor: (UIColor*)color;
- (void)hideIfNeeded;
@end

@interface UIScreen ()
- (CGRect)_referenceBounds;
@end

@interface UIImageAsset ()
@property(nonatomic, assign) NSString *assetName;
@end

@interface UIWindow ()
- (void)_setSecure:(BOOL)arg1;
@end

@interface SBApplication: NSObject
-(NSString*)bundleIdentifier;
@end

@interface SpringBoard: UIApplication
- (id)_accessibilityFrontMostApplication;
-(void)frontDisplayDidChange: (id)arg1;
@end

@interface UIApplication ()
- (UIDeviceOrientation)_frontMostAppOrientation;
- (BOOL)launchApplicationWithIdentifier:(id)arg1 suspended:(BOOL)arg2;
@end

@interface UIImage ()
@property(nonatomic, assign) CGSize pixelSize;
- (UIImage *)sbf_resizeImageToSize:(CGSize)size;
@end

@interface _UIAssetManager
+ (id)assetManagerForBundle:(NSBundle *)bundle;
- (UIImage *)imageNamed:(NSString *)name;
@end

@interface UIStatusBarItem
@property(nonatomic, assign) NSString *indicatorName;
@property(nonatomic, assign) Class viewClass;
@end

@interface UIStatusBarItemView
@property(nonatomic, assign) UIStatusBarItem *item;
@end

@interface UIStatusBarIndicatorItemView: UIStatusBarItemView
@end

@interface SBMainSwitcherViewController: UIViewController
- (BOOL)isMainSwitcherVisible;
@end