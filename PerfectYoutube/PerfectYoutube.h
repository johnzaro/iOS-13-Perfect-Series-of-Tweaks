@interface YTQTMButton: UIButton
@end

@interface YTPivotBarItemView: UIView
@property(retain, nonatomic) YTQTMButton *_Nullable navigationButton;
@end

@interface YTPivotBarView: UIView
@property(retain, nonatomic) YTPivotBarItemView *_Nullable itemView4;
@end

@interface YTRightNavigationButtons
@property(readonly, nonatomic) YTQTMButton *creationButton;
@end