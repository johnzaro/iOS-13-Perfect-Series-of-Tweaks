#import <Cephei/HBPreferences.h>

@interface SafariPreferences: NSObject
{
    HBPreferences *_preferences;

    BOOL _enabled;
    BOOL _addNewTabButton;
    BOOL _showOpenTabsCount;
    BOOL _colorize;
    BOOL _fullScreen;
    BOOL _alwaysShowTabs;
    BOOL _useTabOverview;
    BOOL _showFullURL;
    BOOL _backgroundPlayback;
    BOOL _showBookmarksBar;
}
+ (instancetype)sharedInstance;
- (BOOL)enabled;
- (BOOL)addNewTabButton;
- (BOOL)showOpenTabsCount;
- (BOOL)colorize;
- (BOOL)fullScreen;
- (BOOL)alwaysShowTabs;
- (BOOL)useTabOverview;
- (BOOL)showFullURL;
- (BOOL)backgroundPlayback;
- (BOOL)showBookmarksBar;
- (BOOL)isIpad;
@end
