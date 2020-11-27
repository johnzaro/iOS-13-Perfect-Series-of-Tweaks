#import "PMURootListController.h"

@implementation PMUAppearanceSettings

- (UIColor*)tintColor
{
    return [UIColor colorWithRed: 0.51 green: 0.35 blue: 0.80 alpha: 1.00];
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
    return [UIColor colorWithRed: 0.51 green: 0.35 blue: 0.80 alpha: 1.00];
}

- (UIColor*)tableViewCellTextColor
{
    return [UIColor colorWithRed: 0.51 green: 0.35 blue: 0.80 alpha: 1.00];
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