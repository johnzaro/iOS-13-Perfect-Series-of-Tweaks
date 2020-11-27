typedef struct CCUILayoutSize
{
	NSUInteger width = 0;
	NSUInteger height = 0;
} CCUILayoutSize;

struct CCUILayoutSize CCUILayoutSizeMake(NSUInteger width, NSUInteger height)
{
	CCUILayoutSize layoutSize;
	layoutSize.width = width;
	layoutSize.height = height;
	return layoutSize;
}

@interface CCUIConnectivityModuleViewController : UIViewController
- (BOOL)isExpanded;
- (NSArray<UIViewController *> *)buttonViewControllers;
- (NSArray<UIViewController *> *)landscapeButtonViewControllers;
- (NSArray<UIViewController *> *)portraitButtonViewControllers;
- (BOOL)_isPortrait;
- (CGSize)_compressedButtonSize;
- (NSInteger)numOfColsCompressed;
- (NSInteger)numOfRowsCompressed;
@end

@interface CCUIModuleViewController : UIViewController
- (void)expandModule;
- (BOOL)isExpanded;
@end

@interface CCUIModuleSettingsManager : NSObject
{
	NSDictionary *_settingsByIdentifier;
	NSHashTable *_observers;
}
- (id)init;
- (void)addObserver:(id)arg1;
- (void)removeObserver:(id)arg1;
- (id)orderedEnabledModuleIdentifiers;
- (id)sortModuleIdentifiers:(id)arg1 forInterfaceOrientation:(NSInteger)arg2;
- (id)moduleSettingsForModuleIdentifier:(NSString *)identifier prototypeSize:(CCUILayoutSize)protoSize;
- (void)_loadSettings;
- (void)_runBlockOnListeners:(id)arg1;
- (void)orderedEnabledModuleIdentifiersChangedForSettingsProvider:(id)arg1;
@end

@interface CCUIModuleSettings : NSObject
{
	CCUILayoutSize _portraitLayoutSize;
	CCUILayoutSize _landscapeLayoutSize;
}
- (BOOL)isEqual:(id)arg1;
- (CCUILayoutSize)layoutSizeForInterfaceOrientation:(NSInteger)orientation;
- (id)initWithPortraitLayoutSize:(CCUILayoutSize)portraitSize landscapeLayoutSize:(CCUILayoutSize)landscapeSize;
@end

@interface _MTBackdropView : UIView
@property(assign, nonatomic) CGFloat luminanceAlpha;
@property(assign, nonatomic) CGFloat blurRadius;
@property(assign, nonatomic) CGFloat saturation;
@property(assign, nonatomic) CGFloat brightness;
@property(assign, nonatomic) CGFloat zoom; //@synthesize zoom=_zoom - In the implementation block
@property(assign, nonatomic) CGFloat rasterizationScale;
@property(nonatomic, retain) UIColor *colorMatrixColor;
@end

@protocol MPUMarqueeViewDelegate
@end

@interface MPUMarqueeView : UIView <CAAnimationDelegate>
{

	NSUUID *_currentAnimationID;
	NSInteger _options;
	NSPointerArray *_coordinatedMarqueeViews;
	MPUMarqueeView *_primaryMarqueeView;
	BOOL _marqueeEnabled;
	CGFloat _contentGap;
	UIView *_contentView;
	id<MPUMarqueeViewDelegate> _delegate;
	CGFloat _marqueeDelay;
	CGFloat _marqueeScrollRate;
	UIView *_viewForContentSize;
	CGSize _contentSize;
	UIEdgeInsets _fadeEdgeInsets;
}

@property(assign, nonatomic) CGFloat contentGap;						   //@synthesize contentGap=_contentGap - In the implementation block
@property(assign, nonatomic) CGSize contentSize;						   //@synthesize contentSize=_contentSize - In the implementation block
@property(nonatomic, readonly) UIView *contentView;						   //@synthesize contentView=_contentView - In the implementation block
@property(assign, nonatomic) UIEdgeInsets fadeEdgeInsets;				   //@synthesize fadeEdgeInsets=_fadeEdgeInsets - In the implementation block
@property(assign, nonatomic) id<MPUMarqueeViewDelegate> delegate;		   //@synthesize delegate=_delegate - In the implementation block
@property(assign, nonatomic) CGFloat marqueeDelay;						   //@synthesize marqueeDelay=_marqueeDelay - In the implementation block
@property(assign, nonatomic) CGFloat marqueeScrollRate;					   //@synthesize marqueeScrollRate=_marqueeScrollRate - In the implementation block
@property(assign, getter=isMarqueeEnabled, nonatomic) BOOL marqueeEnabled; //@synthesize marqueeEnabled=_marqueeEnabled - In the implementation block
@property(nonatomic, readonly) NSArray *coordinatedMarqueeViews;
@property(nonatomic, retain) UIView *viewForContentSize; //@synthesize viewForContentSize=_viewForContentSize - In the implementation block
@property(readonly) NSUInteger hash;
@property(readonly) Class superclass;
@property(copy, readonly) NSString *description;
@property(copy, readonly) NSString *debugDescription;
- (id)initWithFrame:(CGRect)arg1;
- (void)setFrame:(CGRect)arg1;
- (CGSize)contentSize;
- (void)layoutSubviews;
- (UIView *)contentView;
- (void)setContentSize:(CGSize)arg1;
- (void)setDelegate:(id<MPUMarqueeViewDelegate>)arg1;
- (void)didMoveToWindow;
- (void)invalidateIntrinsicContentSize;
- (void)setBounds:(CGRect)arg1;
- (id<MPUMarqueeViewDelegate>)delegate;
- (CGFloat)_duration;
- (void)animationDidStop:(id)arg1 finished:(BOOL)arg2;
- (CGSize)intrinsicContentSize;
- (UIView *)viewForLastBaselineLayout;
- (void)setMarqueeEnabled:(BOOL)arg1;
- (UIView *)viewForFirstBaselineLayout;
- (void)_createMarqueeAnimationIfNeeded;
- (void)_tearDownMarqueeAnimation;
- (void)_applyMarqueeFade;
- (void)addCoordinatedMarqueeView:(id)arg1;
- (void)_createMarqueeAnimationIfNeededWithMaximumDuration:(CGFloat)arg1 beginTime:(CGFloat)arg2;
- (void)setMarqueeDelay:(CGFloat)arg1;
- (void)setMarqueeScrollRate:(CGFloat)arg1;
- (void)setViewForContentSize:(UIView *)arg1;
- (NSArray *)coordinatedMarqueeViews;
- (CGFloat)contentGap;
- (UIEdgeInsets)fadeEdgeInsets;
- (CGFloat)marqueeDelay;
- (CGFloat)marqueeScrollRate;
- (UIView *)viewForContentSize;
- (void)setContentGap:(CGFloat)arg1;
- (BOOL)isMarqueeEnabled;
- (void)setMarqueeEnabled:(BOOL)arg1 withOptions:(NSInteger)arg2;
- (void)resetMarqueePosition;
- (void)setFadeEdgeInsets:(UIEdgeInsets)arg1;
@end

@interface MediaControlsTimeControl : UIControl
{
	NSArray *_defaultConstraints;
	NSArray *_trackingConstraints;
	NSArray *_initialConstraints;
}
@property(assign, nonatomic) NSInteger style;
@property(assign, getter=isEmpty, nonatomic) BOOL empty;
@property(assign, getter=isTimeControlOnScreen, nonatomic) BOOL timeControlOnScreen;
- (BOOL)isCurrentlyTracking;
- (BOOL)isEmpty;
- (void)updateLabelAvoidance;
- (void)cancelTrackingWithEvent:(id)event;
@property(nonatomic, retain) NSArray *savedTrackingConstraints;
- (BOOL)isOnControlCenter;
- (void)setIsOnControlCenter:(BOOL)value;
@end

@interface MediaControlsHeaderView : UIView
@property(nonatomic, retain) UIImageView *artworkView;
@property(nonatomic, retain) UIView *artworkBackground;
@property(nonatomic, retain) UIView *artworkBackgroundView;
@property(nonatomic, retain) UIImageView *placeholderArtworkView;
@property(nonatomic, retain) UIButton *launchNowPlayingAppButton;
@property(nonatomic, retain) MPUMarqueeView *titleMarqueeView;
@property(nonatomic, retain) MPUMarqueeView *primaryMarqueeView;
@property(nonatomic, retain) MPUMarqueeView *secondaryMarqueeView;
@property(nonatomic, retain) UILabel *primaryLabel;
@property(nonatomic, retain) UILabel *secondaryLabel;
@property(nonatomic, retain) UIView *routeLabel;
@property(assign, nonatomic) BOOL shouldUsePlaceholderArtwork;
@property(nonatomic, retain) NSString *titleString;
@property(nonatomic, retain) NSString *primaryString;
@property(nonatomic, retain) NSString *secondaryString;
- (void)setStyle:(NSInteger)style;
@property(nonatomic, retain) _MTBackdropView *artworkOverlayView;
- (BOOL)isOnControlCenter;
- (void)setIsOnControlCenter:(BOOL)value;
@end

@interface MediaControlsTransportStackView : UIView
@property(assign, nonatomic) NSInteger style;
@end

@interface MediaControlsContainerView : UIView
@property(nonatomic, retain) MediaControlsTransportStackView *mediaControlsTransportStackView;
@property(retain, nonatomic) MediaControlsTransportStackView *transportStackView;
@property(nonatomic, retain) MediaControlsTimeControl *mediaControlsTimeControl;
@property(retain, nonatomic) MediaControlsTimeControl *timeControl;
@property(assign, nonatomic) NSInteger mediaControlsPlayerState;
@property(assign, nonatomic) NSInteger style;
@property(assign, getter=isTimeControlOnScreen, nonatomic) BOOL timeControlOnScreen;
@property(nonatomic, retain) UIVisualEffectView *primaryVisualEffectView;
- (BOOL)isTimeControlOnScreen;
- (BOOL)isOnControlCenter;
- (void)setIsOnControlCenter:(BOOL)value;
@end

@interface MediaControlsParentContainerView : UIView
@property(nonatomic, retain) MediaControlsContainerView *containerView;
- (void)setStyle:(NSInteger)style;
@end

@interface MediaControlsVolumeContainerView : UIView
@property(assign, nonatomic) NSInteger style;
- (void)setOnScreen:(BOOL)onScreen;
@end

@interface UIView (ORHPrivate)
@property(assign, setter=_setContinuousCornerRadius:, nonatomic) CGFloat _continuousCornerRadius;
@property(nonatomic, retain) NSObject *delegate;
- (BOOL)shouldForwardSelector:(SEL)aSelector;
- (void)_setContinuousCornerRadius:(CGFloat)radius;
- (void)nc_applyVibrantStyling:(id)styling;
- (UIImage *)_imageFromRect:(CGRect)rect;
- (void)nc_removeAllVibrantStyling;
- (BOOL)_shouldAnimatePropertyWithKey:(NSString *)key;
- (void)bs_setHitTestingDisabled:(BOOL)disabled;
- (UIViewController *)_viewControllerForAncestor;
- (UIWindow *)window;
@end

@interface MediaControlsPanelViewController : UIViewController
@property(nonatomic, retain) MediaControlsHeaderView *headerView;
@property(nonatomic, retain) MediaControlsParentContainerView *parentContainerView;
@property(nonatomic, retain) MediaControlsVolumeContainerView *volumeContainerView;
+ (instancetype)panelViewControllerForCoverSheet;
@property(assign, nonatomic) NSInteger style;
- (void)willTransitionToSize:(CGSize)arg1 withCoordinator:(id)arg2;
- (void)setOnScreen:(BOOL)arg1;
- (void)_updateStyle;
@property(nonatomic, assign) CGFloat cachedExpandedHeight;
@end

@interface MRPlatterViewController : UIViewController
@property(nonatomic, retain) MediaControlsHeaderView *headerView;
@property(retain, nonatomic) MediaControlsHeaderView *nowPlayingHeaderView;
@property(nonatomic, retain) MediaControlsParentContainerView *parentContainerView;
@property(nonatomic, retain) MediaControlsVolumeContainerView *volumeContainerView;
+ (instancetype)panelViewControllerForCoverSheet;
@property(assign, nonatomic) NSInteger style;
- (void)willTransitionToSize:(CGSize)arg1 withCoordinator:(id)arg2;
- (void)setOnScreen:(BOOL)arg1;
- (void)_updateStyle;
- (BOOL)isOnControlCenter;
- (void)setIsOnControlCenter: (BOOL)value;
@end

@interface CCUIControlCenterPositionProviderPackingRule : NSObject
{

	NSUInteger _packFrom;
	NSUInteger _packingOrder;
	CCUILayoutSize _sizeLimit;
}

@property(nonatomic, readonly) NSUInteger packFrom;
@property(nonatomic, readonly) NSUInteger packingOrder;
@property(nonatomic, readonly) CCUILayoutSize sizeLimit;
- (id)initWithPackFrom:(NSUInteger)packFrom packingOrder:(NSUInteger)packingOrder sizeLimit:(CCUILayoutSize)sizeLimit;
- (NSUInteger)packFrom;
- (NSUInteger)packingOrder;
- (CCUILayoutSize)sizeLimit;
@end

@interface MediaControlsCollectionViewController : UIViewController
@property(assign, nonatomic) BOOL displayMultipleDestinations;
@property(assign, nonatomic) NSInteger displayMode;
@property(nonatomic, retain) NSArray *visibleBottomViewControllers;
- (CGFloat)_heightForCompact;
- (void)viewWillTransitionToSize:(CGSize)size;
- (void)_updateContentInsets;
- (void)_updateContentSize;
@end

@interface MediaControlsEndpointsViewController : MediaControlsCollectionViewController
- (CGFloat)preferredExpandedContentHeight;
- (CGFloat)preferredExpandedContentWidth;
- (void)_adjustForEnvironmentChangeWithSize:(CGSize)size transitionCoordinator:(id)coordinator;
@end
