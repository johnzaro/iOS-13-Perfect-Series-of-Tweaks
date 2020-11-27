@interface _UIStatusBarStringView : UILabel
@property(nonatomic, copy) NSString *text;
@property(nonatomic) NSTextAlignment textAlignment;
@property(nonatomic) NSInteger numberOfLines;
@property(nonatomic, copy) NSAttributedString *attributedText;
- (BOOL)hasGestureRecognizer;
- (void)setHasGestureRecognizer:(BOOL)arg;
- (void)openDoubleTapApp;
- (void)openHoldApp;
- (void)updateAlarms;
@end

@interface UIApplication ()
- (BOOL)launchApplicationWithIdentifier:(id)arg1 suspended:(BOOL)arg2;
@end

@interface SBScheduledAlarmObserver: NSObject
+ (id)sharedInstance;
- (id)init;
- (void)_nextAlarmChanged: (id)arg1;
@end

@interface MTAlarm
@property(nonatomic, readonly) NSDate *nextFireDate;
@end

@interface MTAlarmManager
- (MTAlarm*)nextAlarmSync;
@end