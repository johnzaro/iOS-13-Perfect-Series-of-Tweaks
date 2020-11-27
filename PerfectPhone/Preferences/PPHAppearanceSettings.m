#import "PPHRootListController.h"

@implementation PPHAppearanceSettings

- (UIColor*)tintColor
{
    return [UIColor colorWithRed: 0.47 green: 0.79 blue: 0.33 alpha: 1.00];
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
    return [UIColor colorWithRed: 0.59 green: 0.95 blue: 0.41 alpha: 1.00];
}

- (UIColor*)tableViewCellTextColor
{
    return [UIColor colorWithRed: 0.47 green: 0.79 blue: 0.33 alpha: 1.00];
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