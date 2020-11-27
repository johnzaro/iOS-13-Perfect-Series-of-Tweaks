#include "PMURootListController.h"
#import "SparkColourPickerView.h"
#import "spawn.h"

@implementation PMURootListController

- (instancetype)init
{
    self = [super init];

    if (self)
	{
        PMUAppearanceSettings *appearanceSettings = [[PMUAppearanceSettings alloc] init];
        self.hb_appearanceSettings = appearanceSettings;
        self.respringButton = [[UIBarButtonItem alloc] initWithTitle: @"Respring" style: UIBarButtonItemStylePlain target: self action: @selector(respring)];
        self.respringButton.tintColor = [UIColor whiteColor];
        self.navigationItem.rightBarButtonItem = self.respringButton;

        self.navigationItem.titleView = [UIView new];
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.font = [UIFont boldSystemFontOfSize: 17];
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.titleLabel.text = @"PerfectMusic";
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
    if (scrollView.contentOffset.y > [PMURootHeaderView headerH] / 2.0) [UIView animateWithDuration: 0.2 animations: ^{ self.titleLabel.alpha = 1.0; }];
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
        alertControllerWithTitle: @"PerfectMusic"
		message: @"Do you really want to Reset All Settings?"
		preferredStyle: UIAlertControllerStyleAlert];
	UIAlertAction *confirmAction = [UIAlertAction actionWithTitle: @"Confirm" style: UIAlertActionStyleDestructive handler:
        ^(UIAlertAction * action)
        {
            [[[HBPreferences alloc] initWithIdentifier: @"com.johnzaro.perfectmusicprefs"] removeAllObjects];

            NSFileManager *manager = [NSFileManager defaultManager];
            [manager removeItemAtPath: @"/var/mobile/Library/Preferences/com.johnzaro.perfectmusicprefs.plist" error: nil];
            [manager removeItemAtPath: @"/var/mobile/Library/Preferences/com.johnzaro.perfectmusicprefs.colors.plist" error: nil];
            
            [self respring];
        }];

	UIAlertAction *cancelAction = [UIAlertAction actionWithTitle: @"Cancel" style: UIAlertActionStyleCancel handler: nil];
	[reset addAction: confirmAction];
	[reset addAction: cancelAction];
	[self presentViewController: reset animated: YES completion: nil];
}

- (void)respring
{
	pid_t pid;
	const char *args[] = {"sbreload", NULL, NULL, NULL};
	posix_spawn(&pid, "usr/bin/sbreload", NULL, NULL, (char *const *)args, NULL);
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

- (void)mailComposeController:(id)arg1 didFinishWithResult:(long long)arg2 error:(id)arg3
{
    [self dismissViewControllerAnimated: YES completion: nil];
}

@end
