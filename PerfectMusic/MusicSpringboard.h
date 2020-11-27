@interface _MPCPlayerShuffleCommand : NSObject
- (BOOL)supportsChangeShuffle;
- (BOOL)supportsAdvanceShuffle;
- (long long)currentShuffleType;
- (id)advance;
@end

@interface NextUpManager: NSObject
- (_Bool)lockscreenEnabled;
@end

@interface NextUpViewController : UIViewController
@property(retain, nonatomic) NextUpManager *manager;
@property(nonatomic) _Bool controlCenter;
@end

@interface _MPCPlayerRepeatCommand : NSObject
- (BOOL)supportsChangeRepeat;
- (BOOL)supportsAdvanceRepeat;
- (long long)currentRepeatType;
- (id)advance;
@end

@interface MPCPlayerResponseTracklist : NSObject
- (_MPCPlayerRepeatCommand *)repeatCommand;
- (_MPCPlayerShuffleCommand *)shuffleCommand;
@end

@interface MPCPlayerResponse : NSObject
- (MPCPlayerResponseTracklist *)tracklist;
@end

@interface MPCPlayerChangeRequest : NSObject
+ (void)performRequest:(id)arg1 completion:(/*^block*/ id)arg2;
@end

@interface SBApplication : NSObject
@end

@interface UILabel ()
- (UIColor*)customTextColor;
- (void)setCustomTextColor:(UIColor*)arg;
@end

@interface UIImageView ()
- (UIColor *)customTintColor;
- (void)setCustomTintColor:(UIColor *)arg;
@end

@interface CAShapeLayer ()
- (UIColor*)customStrokeColor;
- (void)setCustomStrokeColor:(UIColor*)arg;
@end

@interface SBMediaController: NSObject
+ (id)sharedInstance;
- (SBApplication*)nowPlayingApplication;
- (id)_nowPlayingInfo;
@end

@interface CSMediaControlsView: UIView
@end

@interface PLPlatterView: UIView
@end

@interface CSAdjunctItemView: UIView
@end

@interface MPButton: UIButton
- (BOOL)isHolding;
@end

@interface LyricifyButton: UIButton
- (void)setColour: (UIColor*)arg;
@end

@interface MediaControlsTransportButton: MPButton
@end

@interface MediaControlsPanelViewController: UIViewController
@end

@interface MediaControlsTransportStackView: UIView
@property(nonatomic, retain) MediaControlsTransportButton *leftButton;
@property(nonatomic, retain) MediaControlsTransportButton *middleButton;
@property(nonatomic, retain) MediaControlsTransportButton *rightButton;
- (MediaControlsTransportButton *)tvRemoteButton;
- (id)_createTransportButton;
- (void)setStyle:(long long)arg1;
- (MediaControlsTransportButton*)tvRemoteButton;
- (MediaControlsTransportButton*)languageOptionsButton;
- (void)_updateButtonVisualStyling:(UIButton *)button;
- (void)colorize;
- (id)initWithFrame: (CGRect)arg1;
- (void)shuffleButtonPressed;
- (void)repeatButtonPressed;
- (MediaControlsTransportButton*)repeatButton;
- (void)setRepeatButton: (MediaControlsTransportButton*)button;
- (MediaControlsTransportButton*)shuffleButton;
- (void)setShuffleButton: (MediaControlsTransportButton*)button;
- (void)_updateButtonLayout;
- (void)updateButtonIcons: (BOOL)arg;
- (void)setResponse: (MPCPlayerResponse*)arg;
- (id)extraButtonsShown;
- (void)setExtraButtonsShown: (id)arg;
- (id)hasExtraButtons;
- (void)setHasExtraButtons:(id)arg;
- (void)layoutSubviews;
- (void)_updateVisualStylingForButtons;
-(MPCPlayerResponse *)response;
@end

@interface CCUICAPackageView: UIView
@end

@interface MediaControlsRoutingButtonView: MPButton
- (CCUICAPackageView*)packageView;
- (void)colorize;
@end

@interface UIView ()
- (id)_viewControllerForAncestor;
- (UIColor *)customBackgroundColor;
- (void)setCustomBackgroundColor:(UIColor *)arg;
- (id)_rootView;
@end

@interface MTVisualStylingProvider: NSObject
- (void)stopAutomaticallyUpdatingView:(id)arg1;
@end

@interface UISlider ()
- (id)_minTrackView;
- (id)_maxTrackView;
- (id)_minValueView;
- (id)_maxValueView;
@end

@interface MPVolumeSlider: UISlider
- (id)thumbImageForState:(unsigned long long)arg1;
@end

@interface MediaControlsVolumeSlider: MPVolumeSlider
- (MTVisualStylingProvider*)visualStylingProvider;
- (void)colorize;
@end

@interface MediaControlsVolumeContainerView: UIView
@property(nonatomic, retain) MediaControlsVolumeSlider *volumeSlider;
@end

@interface MediaControlsMasterVolumeSlider : MediaControlsVolumeSlider
- (void)colorize;
@end

@interface MPRouteLabel: UIView
@property (nonatomic,readonly) UILabel *titleLabel;
- (void)setTextColor:(UIColor*)arg1;
@end

@interface UILabel ()
- (void)mt_removeAllVisualStyling;
@end

@interface MediaControlsTimeControl : UIControl
@property(nonatomic, retain) UIView *elapsedTrack;
@property(nonatomic, retain) UIView *remainingTrack;
@property(nonatomic, retain) UIView *knobView;
@property(nonatomic, retain) UILabel *elapsedTimeLabel;
@property(nonatomic, retain) UILabel *remainingTimeLabel;
@property(nonatomic, retain) UILabel *liveLabel;
@property(nonatomic, retain) UIView *liveBackground;
- (MTVisualStylingProvider*)visualStylingProvider;
- (void)colorize;
@end

@interface MediaControlsContainerView: UIView
- (MediaControlsTimeControl*)timeControl;
- (MediaControlsTransportStackView*)transportStackView;
@end

@interface MediaControlsParentContainerView: UIView
- (MediaControlsContainerView*)containerView;
@end

@interface MTMaterialView: UIView
@end

@interface MPArtworkCatalog : NSObject
@end

@interface MediaControlsHeaderView: UIView
@property(nonatomic, retain) MTMaterialView *artworkBackground;
@property(nonatomic, retain) UIImageView *placeholderArtworkView;
@property(nonatomic, retain) UIImageView *artworkView;
@property(nonatomic, retain) UIView *shadow;
@property(nonatomic, retain) MPRouteLabel *routeLabel;
@property(nonatomic, retain) UILabel *primaryLabel;
@property(nonatomic, retain) UILabel *secondaryLabel;
- (MediaControlsRoutingButtonView*)routingButton;
- (MTVisualStylingProvider*)visualStylingProvider;
- (UIView*)shadow;
- (MTMaterialView*)artworkBackground;
- (void)colorize;
- (void)colorizeNextUp;
- (void)observeValueForKeyPath: (NSString*)keyPath ofObject: (id)object change: (NSDictionary<NSKeyValueChangeKey, id>*)change context: (void*)context;
@end

@interface NextUpMediaHeaderView: MediaControlsHeaderView
- (void)updateTextColor;
@end

@interface MediaControlsRoutingCornerView
- (void)colorize;
@end

@interface MediaControlsMaterialView : UIView
@end

@interface MRPlatterViewController : UIViewController
@property(nonatomic, retain) MediaControlsRoutingCornerView *routingCornerView;
+ (id)coverSheetPlatterViewController;
- (MediaControlsParentContainerView*)parentContainerView;
- (MediaControlsHeaderView*)nowPlayingHeaderView;
- (MediaControlsVolumeContainerView*)volumeContainerView;
- (UIView*)backgroundView;
- (BOOL)isOnScreen;
- (void)colorize;
- (BOOL)isViewControllerOfLockScreenMusicWidget;
- (BOOL)isViewControllerOfControlCenterMusicWidget;
@end
