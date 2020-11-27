@interface _UIBatteryView: UIView
@property NSInteger chargingState;
@property CGFloat chargePercent;
@property BOOL saverModeActive;
@property(nonatomic, readwrite) UIColor *fillColor;
@property(nonatomic, retain) UIColor *backupFillColor;
@property(nonatomic, retain) UILabel *percentLabel;
- (void)updatePercentageColor;
- (id)hasGestureRecognizer;
- (void)setHasGestureRecognizer:(id)arg;
- (void)fireDoubleTapAction;
- (void)fireHoldAction;
@end

@interface _UIStaticBatteryView: _UIBatteryView
@end

@interface UIApplication ()
- (BOOL)launchApplicationWithIdentifier:(id)arg1 suspended:(BOOL)arg2;
@end

@interface UIDevice ()
- (long long)_feedbackSupportLevel;
@end

@interface _CDBatterySaver: NSObject
+ (id)batterySaver;
- (BOOL)setPowerMode:(long long)arg1 error:(id*)arg2;
@end