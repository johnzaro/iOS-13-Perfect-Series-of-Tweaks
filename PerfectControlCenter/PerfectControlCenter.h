@interface UIView ()
- (id)_viewControllerForAncestor;
@end

@interface MTMaterialView : UIView
@end

@interface CCUIContentModuleContentContainerView: UIView
- (void)setCompactContinuousCornerRadius: (double)arg1;
- (void)setExpandedContinuousCornerRadius: (double)arg1;
@end

@interface CCUIHeaderPocketView: UIView
@end

@interface CCUIModularControlCenterOverlayViewController: UIViewController
- (long long)overlayInterfaceOrientation;
- (UIView*)overlayContainerView;
- (UIScrollView*)overlayScrollView;
- (CCUIHeaderPocketView*)overlayHeaderView;
- (void)fixStatusBarOnDismiss;
- (void)moveToBottom;
@end

@interface CCUIBaseSliderView: UIView
@property(nonatomic, retain) UILabel *percentLabel;
- (float)value;
@end

@interface CCUILabeledRoundButton
@property(nonatomic, copy, readwrite) NSString *title;
@end

@interface SBWiFiManager
- (id)sharedInstance;
- (void)setWiFiEnabled: (BOOL)enabled;
- (bool)wiFiEnabled;
@end

@interface BluetoothManager
- (id)sharedInstance;
- (void)setEnabled: (BOOL)enabled;
- (bool)enabled;
- (void)setPowered: (BOOL)powered;
- (bool)powered;
@end