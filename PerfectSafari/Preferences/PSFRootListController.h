#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSHeaderFooterView.h>
#import <CepheiPrefs/HBRootListController.h>
#import <CepheiPrefs/HBAppearanceSettings.h>
#import <Cephei/HBPreferences.h>

@interface PSFAppearanceSettings: HBAppearanceSettings
@end

@interface PSFRootHeaderView: UITableViewHeaderFooterView<PSHeaderFooterView>
{
    UIImageView *_headerImageView;
    CGFloat _aspectRatio;
}
+ (CGFloat)headerH;
@end

@interface PSFRootListController: HBRootListController
{
    UITableView *_table;
}
@property(nonatomic, retain) UIBarButtonItem *closeSafariButton;
@property(nonatomic, retain) UILabel *titleLabel;
- (void)closeSafari;
- (void)respring;
@end

@interface MFMailComposeViewController: UINavigationController
+ (BOOL)canSendMail;
- (void)setMailComposeDelegate: (id)arg1;
- (id)mailComposeDelegate;
- (void)setToRecipients: (id)arg1;
@end