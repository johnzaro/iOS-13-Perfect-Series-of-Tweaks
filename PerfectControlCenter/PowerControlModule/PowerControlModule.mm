#import "PowerControlModule.h"
#import "../ControlCenterPreferences.h"
#import <spawn.h>
#import <sys/wait.h>
#import <objc/runtime.h>

// Original tweak by @Muirey03: https://github.com/Muirey03/PowerModule

@implementation PowerControlModuleContentViewController

- (id)initWithNibName: (NSString*)name bundle: (NSBundle*)bundle
{
	self = [super initWithNibName: name bundle: bundle];
	if(self)
	{
		_buttons = [NSMutableArray new];
		self.view.clipsToBounds = YES;

		_respringBtn = [[RespringButtonController alloc] initWithGlyphImage: [UIImage imageNamed: @"Respring" inBundle: [NSBundle bundleForClass: [self class]] compatibleWithTraitCollection: nil] highlightColor: [UIColor greenColor] useLightStyle: YES];
		[self setupButtonViewController:_respringBtn title: @"Respring" hidden: NO];

		_UICacheBtn = [[UICacheButtonController alloc] initWithGlyphImage: [UIImage imageNamed: @"UICache" inBundle: [NSBundle bundleForClass: [self class]] compatibleWithTraitCollection: nil] highlightColor: [UIColor greenColor] useLightStyle: YES];
		[self setupButtonViewController:_UICacheBtn title: @"UICache" hidden: YES];

		_rebootBtn = [[RebootButtonController alloc]initWithGlyphImage: [UIImage imageNamed: @"Reboot" inBundle: [NSBundle bundleForClass: [self class]] compatibleWithTraitCollection: nil] highlightColor: [UIColor greenColor] useLightStyle: YES];
		[self setupButtonViewController: _rebootBtn title: @"Reboot" hidden: YES];

		_safemodeBtn = [[SafemodeButtonController alloc] initWithGlyphImage: [UIImage imageNamed: @"SafeMode" inBundle: [NSBundle bundleForClass: [self class]] compatibleWithTraitCollection: nil] highlightColor: [UIColor greenColor] useLightStyle: YES];
		[self setupButtonViewController: _safemodeBtn title: @"Safemode" hidden: YES];

		_powerDownBtn = [[PowerDownButtonController alloc]initWithGlyphImage: [UIImage imageNamed: @"PowerDown" inBundle: [NSBundle bundleForClass: [self class]] compatibleWithTraitCollection: nil] highlightColor: [UIColor greenColor] useLightStyle: YES];
		[self setupButtonViewController: _powerDownBtn title: @"Power Down" hidden: YES];

		_ldRestartBtn = [[LDRestartButtonController alloc]initWithGlyphImage: [UIImage imageNamed: @"LDRestart" inBundle: [NSBundle bundleForClass: [self class]] compatibleWithTraitCollection: nil] highlightColor: [UIColor greenColor] useLightStyle: YES];
		[self setupButtonViewController: _ldRestartBtn title: @"LDRestart" hidden: YES];
	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	if([[objc_getClass("ControlCenterPreferences") sharedInstance] isIpad])
		_preferredExpandedContentWidth = [[UIScreen mainScreen] _referenceBounds].size.width * 0.4;
	else
		_preferredExpandedContentWidth = [[UIScreen mainScreen] _referenceBounds].size.width * 0.856;
		
	_preferredExpandedContentHeight = _preferredExpandedContentWidth * 1.4;
}

- (void)setupButtonViewController: (PowerControlModuleButtonViewController*)button title: (NSString*)title hidden: (BOOL)hidden
{
	[button setTitle: title];
	[button setLabelsVisible: hidden];
	[[button view] setAlpha: (CGFloat)!hidden];
	[button setCollapsedAlpha: [[button view] alpha]];
	if([button respondsToSelector: @selector(setUseAlternateBackground:)])
		[button setUseAlternateBackground: NO];
	[self addChildViewController: button];
	[[self view] addSubview: [button view]];
	[_buttons addObject: button];

	[[button view] setTranslatesAutoresizingMaskIntoConstraints: NO];
	[button setWidthConstraint: [[[button view] widthAnchor] constraintEqualToConstant: 0]];
	[button setHeightConstraint: [[[button view] heightAnchor] constraintEqualToConstant: 0]];
	[button setCenterXConstraint: [[[button view] centerXAnchor] constraintEqualToAnchor: [[self view] leadingAnchor]]];
	[button setTopConstraint: [[[button view] topAnchor] constraintEqualToAnchor: [[self view] topAnchor]]];
	[NSLayoutConstraint activateConstraints: @[[button widthConstraint], [button heightConstraint], [button centerXConstraint], [button topConstraint]]];
}

- (void)viewWillAppear: (BOOL)animated
{
	[super viewWillAppear: animated];
	[self layoutCollapsed];
}

- (void)layoutCollapsed
{
	CGSize size = [[self view] frame].size;
	CGFloat btnSize = [[_respringBtn view] sizeThatFits: size].width;
	CGFloat padding = (size.width - btnSize) / 2;
	CGFloat smallCenter = padding + btnSize / 2;

	[[_respringBtn view] setAlpha: [_respringBtn collapsedAlpha]];
	[_respringBtn setLabelsVisible: NO];
	[[_respringBtn widthConstraint] setConstant: btnSize];
	[[_respringBtn heightConstraint] setConstant: btnSize];
	[[_respringBtn centerXConstraint] setConstant: smallCenter];
	[[_respringBtn topConstraint] setConstant: padding];
}

- (void)layoutExpanded
{
	CGSize size = [[self view] frame].size;
	CGFloat oldBtnWidth = [[_respringBtn view] intrinsicContentSize].width;
	CGFloat ySpacing = (size.height - 3 * oldBtnWidth) / 7;
	CGFloat xOffset = (size.width - 2 * oldBtnWidth) / 4;
	CGFloat xCenterLeft = xOffset + oldBtnWidth / 2;
	CGFloat xCenterRight = size.width - xCenterLeft;
	CGFloat newBtnHeight = (size.height - 4 * ySpacing) / 3;

	for (PowerControlModuleButtonViewController* btn in _buttons)
	{
		[[btn view] setAlpha: 1];
		[btn setLabelsVisible: YES];
		[[btn widthConstraint] setConstant: (size.width / 2)];
		[[btn heightConstraint] setConstant: newBtnHeight];
	}

	[[_respringBtn centerXConstraint] setConstant: xCenterLeft];
	[[_respringBtn topConstraint] setConstant: ySpacing];

	[[_ldRestartBtn centerXConstraint] setConstant: xCenterRight];
	[[_ldRestartBtn topConstraint] setConstant: ySpacing];

	[[_safemodeBtn centerXConstraint] setConstant: xCenterLeft];
	[[_safemodeBtn topConstraint] setConstant: 2 * ySpacing + newBtnHeight];

	[[_UICacheBtn centerXConstraint] setConstant: xCenterRight];
	[[_UICacheBtn topConstraint] setConstant: 2 * ySpacing + newBtnHeight];

	[[_powerDownBtn centerXConstraint] setConstant: xCenterLeft];
	[[_powerDownBtn topConstraint] setConstant: 3 * ySpacing + 2 * newBtnHeight];

	[[_rebootBtn centerXConstraint] setConstant: xCenterRight];
	[[_rebootBtn topConstraint] setConstant: 3 * ySpacing + 2 * newBtnHeight];
}

- (void)willTransitionToExpandedContentMode: (BOOL)expanded
{
	_expanded = expanded;
}

- (void)viewWillTransitionToSize: (CGSize)size withTransitionCoordinator: (id<UIViewControllerTransitionCoordinator>)coordinator
{
	[super viewWillTransitionToSize: size withTransitionCoordinator: coordinator];

	[coordinator animateAlongsideTransition: ^(id<UIViewControllerTransitionCoordinatorContext> context)
	{
		if (_expanded)
			[self layoutExpanded];
		else
			[self layoutCollapsed];

		[[self view] layoutIfNeeded];
	} completion: nil];
}

- (BOOL)_canShowWhileLocked
{
	return YES;
}

@end

@implementation PowerControlModule

- (id)init
{
	if((self = [super init]))
		_contentViewController = [[PowerControlModuleContentViewController alloc] init];
	return self;
}

- (CCUILayoutSize)moduleSizeForOrientation: (int)orientation
{
	return (CCUILayoutSize){1, 1};
}

@end

@implementation PowerControlModuleButtonViewController

- (BOOL)_canShowWhileLocked
{
	return YES;
}

@end

@implementation RespringButtonController

- (void)buttonTapped: (id)arg1
{
	 if([[objc_getClass("ControlCenterPreferences") sharedInstance] respringConfirmation])
	 {
		UIAlertController *confirmation = [UIAlertController alertControllerWithTitle: @"Respring?" message: @"Are you sure you want to respring?" preferredStyle: UIAlertControllerStyleAlert];
		UIAlertAction *actionOK = [UIAlertAction actionWithTitle: @"OK" style: UIAlertActionStyleDefault handler: ^(UIAlertAction *_Nonnull action) { [self respring]; }];
		UIAlertAction *cancel = [UIAlertAction actionWithTitle: @"Cancel" style: UIAlertActionStyleCancel handler: nil];
		[confirmation addAction: actionOK];
		[confirmation addAction: cancel];
		[self presentViewController: confirmation animated: YES completion: nil];
	 }
	 else
	 	[self respring];
}

- (void)respring
{
	pid_t pid;
	int status;
	const char* args[] = {"sbreload", NULL};
	posix_spawn(&pid, "/usr/bin/sbreload", NULL, NULL, (char *const*)args, NULL);
	waitpid(pid, &status, WEXITED);
}

@end

@implementation LDRestartButtonController

- (void)buttonTapped: (id)arg1
{
	 if([[objc_getClass("ControlCenterPreferences") sharedInstance] ldRestartConfirmation])
	 {
		UIAlertController *confirmation = [UIAlertController alertControllerWithTitle: @"LDRestart?" message: @"Are you sure you want to LDRestart?" preferredStyle: UIAlertControllerStyleAlert];
		UIAlertAction *actionOK = [UIAlertAction actionWithTitle: @"OK" style: UIAlertActionStyleDefault handler: ^(UIAlertAction *_Nonnull action) { [self ldRestart]; }];
		UIAlertAction *cancel = [UIAlertAction actionWithTitle: @"Cancel" style: UIAlertActionStyleCancel handler: nil];
		[confirmation addAction: actionOK];
		[confirmation addAction: cancel];
		[self presentViewController: confirmation animated: YES completion: nil];
	 }
	 else
	 	[self ldRestart];
}

- (void)ldRestart
{
	pid_t pid;
	int status;
	const char* args[] = {"mobileldrestart", NULL};
	posix_spawn(&pid, "/usr/bin/mobileldrestart", NULL, NULL, (char *const*)args, NULL);
	waitpid(pid, &status, WEXITED);
}

@end

@implementation SafemodeButtonController

- (void)buttonTapped: (id)arg1
{
	 if([[objc_getClass("ControlCenterPreferences") sharedInstance] safeModeConfirmation])
	 {
		UIAlertController *confirmation = [UIAlertController alertControllerWithTitle: @"Safemode?" message: @"Are you sure you want to enter safemode?" preferredStyle: UIAlertControllerStyleAlert];
		UIAlertAction *actionOK = [UIAlertAction actionWithTitle: @"OK" style: UIAlertActionStyleDefault handler: ^(UIAlertAction *_Nonnull action) { [self safemode];  }];
		UIAlertAction *cancel = [UIAlertAction actionWithTitle: @"Cancel" style: UIAlertActionStyleCancel handler: nil];
		[confirmation addAction: actionOK];
		[confirmation addAction: cancel];
		[self presentViewController: confirmation animated: YES completion: nil];
	 }
	 else
	 	[self safemode];
}

- (void)safemode
{
	pid_t pid;
	int status;
	const char* args[] = {"killall", "-SEGV", "SpringBoard", NULL};
	posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char *const*)args, NULL);
	waitpid(pid, &status, WEXITED);
}

@end

@implementation UICacheButtonController

- (void)buttonTapped: (id)arg1
{
	 if([[objc_getClass("ControlCenterPreferences") sharedInstance] uiCacheConfirmation])
	 {
		UIAlertController *confirmation = [UIAlertController alertControllerWithTitle: @"UICache?" message: @"Are you sure you want to run uicache?" preferredStyle: UIAlertControllerStyleAlert];
		UIAlertAction *actionOK = [UIAlertAction actionWithTitle: @"OK" style: UIAlertActionStyleDefault handler: ^(UIAlertAction *_Nonnull action) { [self UICache]; }];
		UIAlertAction *cancel = [UIAlertAction actionWithTitle: @"Cancel" style: UIAlertActionStyleCancel handler: nil];
		[confirmation addAction: actionOK];
		[confirmation addAction: cancel];
		[self presentViewController: confirmation animated: YES completion: nil];
	 }
	 else
	 	[self UICache];
}

- (void)UICache
{
	pid_t pid;
	int status;
	const char* args[] = {"uicache", NULL};
	posix_spawn(&pid, "/usr/bin/uicache", NULL, NULL, (char *const*)args, NULL);
	waitpid(pid, &status, WEXITED);
}

@end

@implementation PowerDownButtonController

- (void)buttonTapped: (id)arg1
{
	 if([[objc_getClass("ControlCenterPreferences") sharedInstance] powerOffConfirmation])
	 {
		UIAlertController *confirmation = [UIAlertController alertControllerWithTitle: @"Power down?" message: @"Are you sure you want to power down?" preferredStyle: UIAlertControllerStyleAlert];
		UIAlertAction *actionOK = [UIAlertAction actionWithTitle: @"OK" style: UIAlertActionStyleDefault handler: ^(UIAlertAction *_Nonnull action) { [self PowerDown]; }];
		UIAlertAction *cancel = [UIAlertAction actionWithTitle: @"Cancel" style: UIAlertActionStyleCancel handler: nil];
		[confirmation addAction: actionOK];
		[confirmation addAction: cancel];
		[self presentViewController: confirmation animated: YES completion: nil];
	 }
	 else
	 	[self PowerDown];
}

- (void)PowerDown
{
	[[objc_getClass("FBSystemService") sharedInstance] shutdownAndReboot: NO];
}

@end

@implementation RebootButtonController

- (void)buttonTapped: (id)arg1
{
	 if([[objc_getClass("ControlCenterPreferences") sharedInstance] rebootConfirmation])
	 {
		UIAlertController *confirmation = [UIAlertController alertControllerWithTitle: @"Reboot?" message: @"Are you sure you want to reboot?" preferredStyle: UIAlertControllerStyleAlert];
		UIAlertAction *actionOK = [UIAlertAction actionWithTitle: @"OK" style: UIAlertActionStyleDefault handler: ^(UIAlertAction *_Nonnull action) { [self reboot]; }];
		UIAlertAction *cancel = [UIAlertAction actionWithTitle: @"Cancel" style: UIAlertActionStyleCancel handler: nil];
		[confirmation addAction: actionOK];
		[confirmation addAction: cancel];
		[self presentViewController: confirmation animated: YES completion: nil];
	}
	else
		[self reboot];
}

- (void)reboot
{
	[[objc_getClass("FBSystemService") sharedInstance] shutdownAndReboot: YES];
}

@end
