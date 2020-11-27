@interface PUOneUpViewController: UIViewController
- (id)pu_debugCurrentAsset;
@end

@interface PUNavigationController
- (UIViewController*)_currentToolbarViewController;
@end

@interface PHAsset: NSObject
- (CGSize)imageSize;
- (id)mainFileURL;
@end

@interface PUPhotoBrowserTitleViewController: UIViewController
- (void)_setNeedsUpdate;
@end
