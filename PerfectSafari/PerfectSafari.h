@class BrowserController, BrowserRootViewController, _SFToolbar, TabController, NavigationBar;

@interface _SFBarTheme: NSObject
+ (instancetype)themeWithTheme:(id)arg1;
@end

@interface UIToolbar (Private)
- (void)_setItemDistribution:(NSInteger)arg1;
@end

@interface UIBarButtonItem (Safari)
- (void)_sf_setTarget:(id)target longPressAction:(SEL)longPressAction;
- (void)_sf_setTarget:(id)target touchDownAction:(SEL)touchDownAction longPressAction:(SEL)longPressAction;
@end

@interface UIBarButtonItem (Private)
@property(assign, setter=_setAdditionalSelectionInsets:, nonatomic) UIEdgeInsets _additionalSelectionInsets;
@end

@interface TabController: NSObject
@property(readonly, nonatomic) NSUInteger numberOfCurrentNonHiddenTabs;
@end

@interface SFBarRegistration: UIResponder
- (id)initWithBar:(id)arg1 barManager:(id)arg2 layout:(NSInteger)arg3 persona:(NSUInteger)arg4;
- (UIBarButtonItem *)UIBarButtonItemForItem:(NSInteger)arg1;
- (UIBarButtonItem *)_newBarButtonItemForSFBarItem:(NSInteger)barItem;
- (BOOL)containsBarItem:(NSInteger)barItem;
@end

@interface _SFToolbar: UIToolbar
@property(nonatomic, weak) SFBarRegistration *barRegistration;
@property(nonatomic, retain) UIBarButtonItem *_reloadItem;
@property(nonatomic, retain) UILabel *tabCountLabel;
@property(nonatomic, retain) UIImage *tabExposeImage;
@property(nonatomic, retain) UIImage *tabExposeImageWithCount;
- (void)updateTabCount;
@end

@interface BrowserRootViewController: UIViewController
@property(nonatomic, weak, readonly) BrowserController *browserController;
@property(readonly, nonatomic) _SFToolbar *bottomToolbar;
@property(readonly, nonatomic) NavigationBar *navigationBar;
@end

@interface BrowserController: UIResponder
@property(nonatomic, readonly) TabController *tabController;
@property(nonatomic, readonly) _SFToolbar *bottomToolbar;
@property(nonatomic, readonly) BrowserRootViewController *rootViewController;
- (void)tabControllerDocumentCountDidChange:(TabController *)tabController;
- (void)setPrivateBrowsingEnabled:(BOOL)arg1;
@end

@interface _SFBarManager: NSObject
@property(nonatomic) BrowserController *delegate;
@end

@interface _SFNavigationBar: UIView
@property(nonatomic, weak) BrowserController *delegate;
@property(nonatomic, readonly) _SFBarTheme *effectiveTheme;
- (id)_toolbarForBarItem:(NSInteger)barItem;
@end

@interface NavigationBar: _SFNavigationBar
@property(nonatomic, readonly) UIButton *reloadButton;
@end

@interface TabDocument: NSObject
@end

@interface TabBarItemView: UIView
@end

@interface TabBar: UIView
@end