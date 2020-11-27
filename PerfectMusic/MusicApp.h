@interface UISlider ()
- (id)_minTrackView;
- (id)_maxTrackView;
- (id)_minValueView;
- (id)_maxValueView;
@end

@interface UIBezierPath ()
+ (id)roundedRectBezierPath: (CGRect)arg1 withTopCornerRadius: (double)arg2 withBottomCornerRadius: (double)arg3;
@end

@interface CALayer ()
-(void)setCornerCurve:(NSString *)arg1;
@end

@interface UIView ()
- (UIColor *)customBackgroundColor;
- (void)setCustomBackgroundColor: (UIColor *)arg;
- (UIColor *)customTintColor;
- (void)setCustomTintColor:(UIColor *)arg;
- (UIView *)contentView;
- (id)_viewControllerForAncestor;
@end

@interface UILabel ()
- (void)_setTextColorFollowsTintColor:(BOOL)arg1;
- (UIColor *)customTextColor;
- (void)setCustomTextColor:(UIColor *)arg;
@end

@interface UIImageView ()
- (UIColor*)customTintColor;
- (void)setCustomTintColor: (UIColor*)arg;
@end

@interface MPRouteButton: UIControl
- (UIColor*)customTintColor;
- (void)setCustomTintColor: (UIColor*)arg;
@end

@interface MPRouteLabel: UILabel
- (UIColor*)customTextColor;
- (void)setCustomTextColor:(UIColor *)arg;
@end

@interface UIButton ()
- (UIColor*)customBackgroundColor;
- (void)setCustomBackgroundColor:(UIColor *)arg;
- (UIColor*)customTintColor;
- (void)setCustomTintColor: (UIColor*)arg;
- (id)specialButton;
- (void)setSpecialButton: (id)type;
- (UIColor*)customTitleColor;
- (void)setCustomTitleColor: (UIColor*)arg;
- (NSString*)currentTitle;
@end

@interface MPButton: UIButton
- (void)updateButtonColor;
- (void)setCustomButtonTintColorWithBackgroundColor: (UIColor*)bgColor;
@end

@interface MPVolumeSlider: UISlider
- (UIView *)thumbView;
- (id)thumbImageForState:(unsigned long long)arg1;
- (void)colorize;
- (UIColor*)customMinimumTrackTintColor;
- (void)setCustomMinimumTrackTintColor: (UIColor*)arg;
- (UIColor*)customMaximumTrackTintColor;
- (void)setCustomMaximumTrackTintColor: (UIColor*)arg;
@end

@interface NowPlayingContentView : UIView
@property(nonatomic, retain) UIImageView *artworkImageView;
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey, id> *)change context:(void *)context;
@end

@interface NowPlayingTransportButton : MPButton
- (void)colorize;
@end

@interface PlayerTimeControl : UIControl
@property(nonatomic, retain) UILabel *liveLabel;
- (void)colorize;
@end

@interface ContextualActionsButton : UIButton
- (void)colorize;
@end

@interface NowPlayingViewController: UIViewController
- (void)colorize;
@end

@interface MiniPlayerViewController: UIViewController
@property(nonatomic, retain) NowPlayingTransportButton *skipButton;
@property(nonatomic, retain) NowPlayingTransportButton *playPauseButton;
@property(nonatomic, retain) UILabel *nowPlayingItemTitleLabel;
@property(nonatomic, retain) MPRouteLabel *nowPlayingItemRouteLabel;
@property(nonatomic, retain) NowPlayingContentView *artworkView;
- (void)colorize;
@end

@interface _TtC16MusicApplication24MiniPlayerViewController: UIViewController
@property(nonatomic, retain) UILabel *nowPlayingItemTitleLabel;
@end

@interface MusicNowPlayingControlsViewController: UIViewController
@property(nonatomic, retain) MPRouteLabel *routeLabel;
@property(nonatomic, retain) MPButton *routeButton;
@property(nonatomic, retain) UILabel *titleLabel;
@property(nonatomic, retain) MPButton *subtitleButton;
@property(nonatomic, retain) ContextualActionsButton *contextButton;
@property(nonatomic, retain) NowPlayingTransportButton *rightButton;
@property(nonatomic, retain) NowPlayingTransportButton *playPauseStopButton;
@property(nonatomic, retain) NowPlayingTransportButton *leftButton;
@property(nonatomic, readonly) MPButton *accessibilityQueueButton;
@property(nonatomic, readonly) MPButton *accessibilityLyricsButton;
- (void)colorize;
@end

@interface NowPlayingHistoryHeaderView : UICollectionReusableView
- (void)colorize;
@end

@interface NowPlayingQueueHeaderView : UICollectionReusableView
- (void)colorize;
@end

@interface NowPlayingQueueViewController : UIViewController
- (void)colorize;
@end

@interface TintColorObservingView: UIView
@end

@interface QueueGradientView: UIView
@end

@interface _TtC16MusicApplication25ArtworkComponentImageView: UIImageView
@end

@interface MPMediaItemArtwork : NSObject
- (CGRect)bounds;
- (id)imageWithSize:(CGSize)arg1;
@end

@interface MPMediaItem: NSObject
- (NSString *)title;
- (MPMediaItemArtwork *)artwork;
@end

@interface MPAVItem: NSObject
@end

@interface MPCModelGenericAVItem: MPAVItem
- (/*^block*/id)artworkCatalogBlock;
@end

@interface MPAVController: NSObject
- (MPAVItem*)currentItem;
@end

@interface _MPCAVController: MPAVController
- (MPMediaItem*)mediaItem;
@end

@interface UIScreen ()
- (CGRect)_referenceBounds;
@end

@interface UIAlertAction ()
@property(nonatomic, copy) void (^handler)(UIAlertAction *action);
@end