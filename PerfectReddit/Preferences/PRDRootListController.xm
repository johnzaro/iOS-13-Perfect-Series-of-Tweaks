#import "PRDRootListController.h"
#import "SparkColourPickerView.h"
#import "spawn.h"

int (*BKSTerminateApplicationForReasonAndReportWithDescription)(NSString *displayIdentifier, int reason, int something, int something2);

@implementation PRDRootListController

- (instancetype)init
{
    self = [super init];

    if (self)
	{
        PRDAppearanceSettings *appearanceSettings = [[PRDAppearanceSettings alloc] init];
        self.hb_appearanceSettings = appearanceSettings;

        UIButton *button = [UIButton buttonWithType: UIButtonTypeCustom];
        button.titleLabel.numberOfLines = 2;
        button.titleLabel.textAlignment = 1;
        button.titleLabel.font = [UIFont systemFontOfSize: 17];
        [button addTarget: self action: @selector(closeReddit) forControlEvents: UIControlEventPrimaryActionTriggered];
        [button setTitle: @"Close\nReddit" forState: UIControlStateNormal];
        [button sizeToFit];

        self.closeRedditButton = [[UIBarButtonItem alloc] initWithCustomView: button];
        self.closeRedditButton.tintColor = [UIColor whiteColor];
        self.navigationItem.rightBarButtonItem = self.closeRedditButton;

        self.navigationItem.titleView = [UIView new];
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.font = [UIFont boldSystemFontOfSize: 17];
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.titleLabel.text = @"PerfectReddit";
		self.titleLabel.alpha = 0.0;
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.navigationItem.titleView addSubview: self.titleLabel];

        [NSLayoutConstraint activateConstraints:
		@[
            [self.titleLabel.topAnchor constraintEqualToAnchor: self.navigationItem.titleView.topAnchor],
            [self.titleLabel.leadingAnchor constraintEqualToAnchor: self.navigationItem.titleView.leadingAnchor],
            [self.titleLabel.trailingAnchor constraintEqualToAnchor: self.navigationItem.titleView.trailingAnchor],
            [self.titleLabel.bottomAnchor constraintEqualToAnchor: self.navigationItem.titleView.bottomAnchor],
        ]];
    }
    return self;
}

- (void)viewWillAppear: (BOOL)animated
{
    [super viewWillAppear: animated];

    CGRect frame = self.table.bounds;
    frame.origin.y = -frame.size.height;

    self.navigationController.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

- (void)scrollViewDidScroll: (UIScrollView*)scrollView
{
    if (scrollView.contentOffset.y > [PRDRootHeaderView headerH] / 2.0) [UIView animateWithDuration: 0.2 animations: ^{ self.titleLabel.alpha = 1.0; }];
	else [UIView animateWithDuration:0.2 animations: ^{ self.titleLabel.alpha = 0.0; }];
}

- (NSArray*)specifiers
{
	if (!_specifiers) _specifiers = [self loadSpecifiersFromPlistName: @"Root" target: self];
	return _specifiers;
}


- (void)reset: (PSSpecifier*)specifier
{
    UIAlertController *reset = [UIAlertController
        alertControllerWithTitle: @"PerfectReddit"
		message: @"Do you really want to Reset All Settings?"
		preferredStyle: UIAlertControllerStyleAlert];
	UIAlertAction *confirmAction = [UIAlertAction actionWithTitle: @"Confirm" style: UIAlertActionStyleDestructive handler:
        ^(UIAlertAction * action)
        {
            [[[HBPreferences alloc] initWithIdentifier: @"com.johnzaro.perfectredditprefs"] removeAllObjects];

            NSFileManager *manager = [NSFileManager defaultManager];
            [manager removeItemAtPath:@"/var/mobile/Library/Preferences/com.johnzaro.perfectredditprefs.plist" error: nil];
            [manager removeItemAtPath:@"/var/mobile/Library/Preferences/com.johnzaro.perfectredditprefs.colors.plist" error: nil];

            [self closeReddit];
            [self closeSettings];
        }];

	UIAlertAction *cancelAction = [UIAlertAction actionWithTitle: @"Cancel" style: UIAlertActionStyleCancel handler: nil];
	[reset addAction: confirmAction];
	[reset addAction: cancelAction];
	[self presentViewController: reset animated: YES completion: nil];
}

- (void)closeSettings
{
	void *bk = dlopen("/System/Library/PrivateFrameworks/BackBoardServices.framework/BackBoardServices", RTLD_LAZY);
	if (bk)
    {
        BKSTerminateApplicationForReasonAndReportWithDescription = (int (*)(NSString*, int, int, int))dlsym(bk, "BKSTerminateApplicationForReasonAndReportWithDescription");
        BKSTerminateApplicationForReasonAndReportWithDescription(@"com.apple.Preferences", 1, 0, 0);
    }
}

- (void)closeReddit
{
	void *bk = dlopen("/System/Library/PrivateFrameworks/BackBoardServices.framework/BackBoardServices", RTLD_LAZY);
	if (bk)
    {
        BKSTerminateApplicationForReasonAndReportWithDescription = (int (*)(NSString*, int, int, int))dlsym(bk, "BKSTerminateApplicationForReasonAndReportWithDescription");
        BKSTerminateApplicationForReasonAndReportWithDescription(@"com.reddit.Reddit", 1, 0, 0);
    }
}

- (void)email
{
	if([%c(MFMailComposeViewController) canSendMail])
	{
		MFMailComposeViewController *mailCont = [[%c(MFMailComposeViewController) alloc] init];
		mailCont.mailComposeDelegate = self;

		[mailCont setToRecipients: [NSArray arrayWithObject: @"johnzrgnns@gmail.com"]];
		[self presentViewController: mailCont animated: YES completion: nil];
	}
}

- (void)reddit
{
	if([[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString: @"reddit://"]])
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"reddit://www.reddit.com/user/johnzaro"]];
	else
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.reddit.com/user/johnzaro"]];
}

-(void)mailComposeController:(id)arg1 didFinishWithResult:(long long)arg2 error:(id)arg3
{
    [self dismissViewControllerAnimated: YES completion: nil];
}

@end
