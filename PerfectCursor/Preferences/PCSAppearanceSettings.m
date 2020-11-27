#import "PCSRootListController.h"

@implementation PCSAppearanceSettings

- (UIColor*)tintColor
{
    return [UIColor colorWithRed: 0.814 green: 0.30 blue: 0.10 alpha: 1.00];
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
    return [UIColor colorWithRed: 0.814 green: 0.30 blue: 0.10 alpha: 1.00];
}

- (UIColor*)tableViewCellTextColor
{
    return [UIColor colorWithRed: 0.814 green: 0.30 blue: 0.10 alpha: 1.00];
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