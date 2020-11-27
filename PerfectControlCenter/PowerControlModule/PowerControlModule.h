@interface UIScreen ()
- (CGRect)_referenceBounds;
@end

@interface FBSystemService: NSObject
+ (id)sharedInstance;
- (void)shutdownAndReboot: (BOOL)reboot;
@end

typedef struct CCUILayoutSize
{
    unsigned long long width;
    unsigned long long height;
} CCUILayoutSize;

@protocol CCUIContentModuleContentViewController<NSObject>
@property(nonatomic, readonly) CGFloat preferredExpandedContentHeight;
@property(nonatomic, readonly) CGFloat preferredExpandedContentWidth;
@optional
- (void)willTransitionToExpandedContentMode: (BOOL)willTransition;
- (CGFloat)preferredExpandedContentWidth;
@required
- (CGFloat)preferredExpandedContentHeight;
@end

@interface CCUILabeledRoundButtonViewController: UIViewController
@property(assign, nonatomic) BOOL labelsVisible;
@property(assign, nonatomic) BOOL useAlternateBackground;
- (id)initWithGlyphImage: (id)arg1 highlightColor: (id)arg2 useLightStyle: (BOOL)arg3;
@end

@interface PowerControlModuleButtonViewController: CCUILabeledRoundButtonViewController
@property(nonatomic, strong) NSLayoutConstraint *widthConstraint;
@property(nonatomic, strong) NSLayoutConstraint *heightConstraint;
@property(nonatomic, strong) NSLayoutConstraint *centerXConstraint;
@property(nonatomic, strong) NSLayoutConstraint *topConstraint;
@property(nonatomic, assign) CGFloat collapsedAlpha;
@end

@interface RespringButtonController: PowerControlModuleButtonViewController
- (void)respring;
@end

@interface LDRestartButtonController: PowerControlModuleButtonViewController
- (void)ldRestart;
@end

@interface SafemodeButtonController: PowerControlModuleButtonViewController
- (void)safemode;
@end

@interface UICacheButtonController: PowerControlModuleButtonViewController
- (void)UICache;
@end

@interface PowerDownButtonController: PowerControlModuleButtonViewController
- (void)PowerDown;
@end

@interface RebootButtonController: PowerControlModuleButtonViewController
- (void)reboot;
@end

@interface PowerControlModuleContentViewController: UIViewController<CCUIContentModuleContentViewController>
@property(nonatomic, readonly) CGFloat preferredExpandedContentHeight;
@property(nonatomic, readonly) CGFloat preferredExpandedContentWidth;
@property(nonatomic, readonly) BOOL providesOwnPlatter;
@property(nonatomic, strong) RespringButtonController *respringBtn;
@property(nonatomic, strong) LDRestartButtonController *ldRestartBtn;
@property(nonatomic, strong) SafemodeButtonController *safemodeBtn;
@property(nonatomic, strong) UICacheButtonController *UICacheBtn;
@property(nonatomic, strong) PowerDownButtonController *powerDownBtn;
@property(nonatomic, strong) RebootButtonController *rebootBtn;
@property(nonatomic, readonly) BOOL expanded;
@property(nonatomic, strong) NSMutableArray<PowerControlModuleButtonViewController*> *buttons;
- (void)setupButtonViewController: (PowerControlModuleButtonViewController*)button title: (NSString*)title hidden: (BOOL)hidden;
- (void)layoutCollapsed;
- (void)layoutExpanded;
@end

@protocol CCUIContentModule <NSObject>
@property(nonatomic, readonly) UIViewController<CCUIContentModuleContentViewController> *contentViewController;
@property(nonatomic, readonly) UIViewController *backgroundViewController;
@optional
- (void)setContentModuleContext: (id)context;
- (UIViewController*)backgroundViewController;
@required
- (UIViewController<CCUIContentModuleContentViewController>*)contentViewController;
@end

@interface PowerControlModule: NSObject<CCUIContentModule>
@property(nonatomic, readonly) PowerControlModuleContentViewController *contentViewController;
@property(nonatomic, readonly) UIViewController *backgroundViewController;
@property(nonatomic, readonly) BOOL smallSize;
@end