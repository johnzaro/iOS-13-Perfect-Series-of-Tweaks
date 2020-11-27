#import "PLSRootListController.h"

@implementation PLSAppearanceSettings

- (UIColor*)tintColor
{
    return [UIColor colorWithRed: 0.00 green: 0.31 blue: 0.67 alpha: 1.00];
}

- (UIColor*)statusBarTintColor
{
    return [UIColor whiteColor];
}

- (UIColor*)navigationBarTitleColor
{
    return [UIColor whiteColor];
}

- (UIColor*)navigationBarTintColor
{
    return [UIColor whiteColor];
}

- (UIColor*)tableViewCellSeparatorColor
{
    return [UIColor clearColor];
}

- (UIColor*)navigationBarBackgroundColor
{
    return [UIColor colorWithRed: 0.00 green: 0.31 blue: 0.67 alpha: 1.00];
}

- (UIColor*)tableViewCellTextColor
{
    return [UIColor colorWithRed: 0.00 green: 0.31 blue: 0.67 alpha: 1.00];
}

- (BOOL)translucentNavigationBar
{
    return NO;
}

- (NSUInteger)largeTitleStyle
{
    return 2;
}

@end