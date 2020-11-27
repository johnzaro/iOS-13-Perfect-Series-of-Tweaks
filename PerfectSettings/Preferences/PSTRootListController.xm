#import "PSTRootListController.h"

int (*BKSTerminateApplicationForReasonAndReportWithDescription)(NSString *displayIdentifier, int reason, int something, int something2);

@implementation PSTRootListController

- (instancetype)init
{
    self = [super init];

    if (self)
	{
        PSTAppearanceSettings *appearanceSettings = [[PSTAppearanceSettings alloc] init];
        self.hb_appearanceSettings = appearanceSettings;

        UIButton *button = [UIButton buttonWithType: UIButtonTypeCustom];
        button.titleLabel.numberOfLines = 2;
        button.titleLabel.textAlignment = 1;
        button.titleLabel.font = [UIFont systemFontOfSize: 17];
        [button addTarget: self action: @selector(closeSettings) forControlEvents: UIControlEventPrimaryActionTriggered];
        [button setTitle: @"Close\nSettings" forState: UIControlStateNormal];
        [button sizeToFit];

        self.closeSettingsButton = [[UIBarButtonItem alloc] initWithCustomView: button];
        self.closeSettingsButton.tintColor = [UIColor whiteColor];
        self.navigationItem.rightBarButtonItem = self.closeSettingsButton;

        self.navigationItem.titleView = [UIView new];
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.font = [UIFont boldSystemFontOfSize: 17];
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.titleLabel.text = @"PerfectSettings";
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
    if (scrollView.contentOffset.y > [PSTRootHeaderView headerH] / 2.0) [UIView animateWithDuration: 0.2 animations: ^{ self.titleLabel.alpha = 1.0; }];
	else [UIView animateWithDuration:0.2 animations: ^{ self.titleLabel.alpha = 0.0; }];
}

- (NSArray*)specifiers
{
	if (!_specifiers) _specifiers = [self loadSpecifiersFromPlistName: @"Root" target: self];
	return _specifiers;
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
