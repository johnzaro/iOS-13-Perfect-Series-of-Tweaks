#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSHeaderFooterView.h>
#import <CepheiPrefs/HBRootListController.h>
#import <CepheiPrefs/HBAppearanceSettings.h>
#import <Cephei/HBPreferences.h>

@interface PPHAppearanceSettings: HBAppearanceSettings
@end

@interface PPHRootHeaderView: UITableViewHeaderFooterView<PSHeaderFooterView>
{
    UIImageView *_headerImageView;
    CGFloat _aspectRatio;
}
+ (CGFloat)headerH;
@end

@interface PPHRootListController: HBRootListController
{
    UITableView *_table;
}
@property(nonatomic, retain) UIBarButtonItem *closePhoneButton;
@property(nonatomic, retain) UILabel *titleLabel;
- (void)closePhone;
@end

@interface MFMailComposeViewController: UINavigationController
+ (BOOL)canSendMail;
- (void)setMailComposeDelegate: (id)arg1;
- (id)mailComposeDelegate;
- (void)setToRecipients: (id)arg1;
@end