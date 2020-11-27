#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSHeaderFooterView.h>
#import <CepheiPrefs/HBRootListController.h>
#import <CepheiPrefs/HBAppearanceSettings.h>
#import <Cephei/HBPreferences.h>

@interface PPTAppearanceSettings: HBAppearanceSettings
@end

@interface PPTRootHeaderView : UITableViewHeaderFooterView <PSHeaderFooterView>
{
    UIImageView *_headerImageView;
    CGFloat _aspectRatio;
}
+ (CGFloat)headerH;
@end

@interface PPTRootListController: HBRootListController
{
    UITableView *_table;
}
@property(nonatomic, retain) UIBarButtonItem *closePhotosButton;
@property(nonatomic, retain) UILabel *titleLabel;
- (void)closePhotos;
@end

@interface MFMailComposeViewController: UINavigationController
+ (BOOL)canSendMail;
- (void)setMailComposeDelegate: (id)arg1;
- (id)mailComposeDelegate;
- (void)setToRecipients: (id)arg1;
@end