#import "PBTRootListController.h"

@implementation PBTAppearanceSettings

- (UIColor*)tintColor
{
    return [UIColor colorWithRed: 0.87 green: 0.45 blue: 0.22 alpha: 1.00];
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
    return [UIColor colorWithRed: 0.87 green: 0.45 blue: 0.22 alpha: 1.00];
}

- (UIColor*)tableViewCellTextColor
{
    return [UIColor colorWithRed: 0.87 green: 0.45 blue: 0.22 alpha: 1.00];
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