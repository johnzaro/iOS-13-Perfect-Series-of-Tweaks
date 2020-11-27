@interface WGWidgetListHeaderView: UIView
@end

@interface MTMaterialView: UIView
@end

@interface WGWidgetPlatterView: UIView
- (UIButton*)showMoreButton;
- (void)colorizeWidget;
- (UIColor*)widgetBackgroundColor;
- (void)setWidgetBackgroundColor: (UIColor*)color;
- (UIColor*)widgetBorderColor;
- (void)setWidgetBorderColor: (UIColor*)color;
@end

@interface PLPlatterHeaderContentView: UIView
@end

@interface WGPlatterHeaderContentView: PLPlatterHeaderContentView
- (UIColor*)iconAverageColor;
- (void)setIconAverageColor: (UIColor*)color;
@end