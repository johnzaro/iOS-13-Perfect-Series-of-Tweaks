@interface CCUIToggleModule: NSObject
@property(assign, getter=isSelected, nonatomic) BOOL selected;
@property(nonatomic, copy, readonly) UIImage *iconGlyph;
@property(nonatomic, copy, readonly) UIImage *selectedIconGlyph;
@property(nonatomic, copy, readonly) UIColor *selectedColor;
- (void)refreshState;
@end

@interface LowPowerModeModule: CCUIToggleModule
{
    BOOL _selected;
}
@end

@interface UIImage ()
+ (UIImage*)imageNamed: (NSString*)name inBundle: (NSBundle*)bundle;
@end

@interface _CDBatterySaver: NSObject
+ (id)batterySaver;
- (BOOL)setPowerMode: (long long)arg1 error: (id*)arg2;
@end
