@interface SBIconProgressView: UIView
@property(nonatomic, strong) UILabel *progressLabel;
@property(nonatomic, strong) UIView *progressBar;
@property(nonatomic, assign) double displayedFraction;
@end

@interface SBFolderController
- (void)_closeFolderTimerFired;
- (BOOL)isOpen;
@end

@interface SBHIconManager: NSObject
- (SBFolderController*)openedFolderController;
@end

@interface SBApplicationIcon: NSObject
- (NSString*)applicationBundleID;
@end

@interface SBIconListGridLayoutConfiguration
- (NSUInteger)numberOfPortraitRows;
- (NSUInteger)numberOfLandscapeRows;
- (NSUInteger)numberOfPortraitColumns;
- (NSUInteger)numberOfLandscapeColumns;
@property(nonatomic, assign) NSString *location;
- (NSString*)findLocation;
@end

@interface SBHIconViewContextMenuWrapperViewController: UIViewController
@end

@interface _UICutoutShadowView: UIView
@end

@interface SBIconImageView: UIImageView
@end

@interface SBDockView: UIView
@end

@interface SBIconView: UIView
- (id)applicationBundleIdentifier;
- (id)applicationBundleIdentifierForShortcuts;
@end

@interface SBSApplicationShortcutItem: NSObject
- (void)setLocalizedTitle:(NSString*)arg1;
- (NSString*)localizedTitle;
- (void)setLocalizedSubtitle:(NSString*)arg1;
- (void)setBundleIdentifierToLaunch:(NSString*)arg1;
@property(nonatomic, retain) NSString *type;
@end

@interface SBWallpaperEffectView: UIView
@property(nonatomic, strong) UIView *blurView;
@end

@interface SBFolderIconImageView: SBIconImageView
- (SBWallpaperEffectView*)backgroundView;
@end

@interface SBFolderBackgroundView: UIView
@end

@interface SBFolderTitleTextField: UITextField
@end

@interface SBIconListPageControl: UIView
@end