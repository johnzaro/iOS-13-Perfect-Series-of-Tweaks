#import "PerfectMessages.h"
#import <Cephei/HBPreferences.h>

static HBPreferences *pref;
static BOOL enabled;
static BOOL returnToMessagesOnClose;
static BOOL easySwitchIMessageSMS;

static BOOL isIMessage;

static void produceHeavyVibration()
{
	UIImpactFeedbackGenerator *gen = [[UIImpactFeedbackGenerator alloc] initWithStyle: UIImpactFeedbackStyleHeavy];
	[gen prepare];
	[gen impactOccurred];
}

%group returnToMessagesListOnCloseGroup

	%hook CKMessagesController

	- (void)prepareForSuspend
	{
		%orig;
		[self showConversationList: NO];
	}

	- (void)prepareForResume
	{
		%orig;
		[self showConversationList: NO];
	}

	- (void)performResumeDeferredSetup
	{
		%orig;
		[self showConversationList: NO];
	}

	- (void)parentControllerDidResume: (BOOL)arg1 animating: (BOOL)arg2
	{
		%orig;
		[self showConversationList: NO];
	}

	- (BOOL)resumeToConversation: (id)arg
	{
		return %orig(nil);
	}

	%end

%end

%group easySwitchIMessageSMSGroup

	// Original tweak by @andrewwiik: https://github.com/andrewwiik/SwitchService

	@implementation PulsingHaloLayer

	- (id)init
	{
		self = [super init];
		if(self)
		{
			[self setEffect: [CALayer new]];
			[[self effect] setOpacity: 0];
			[[self effect] setContentsScale: [[UIScreen mainScreen] scale]];
			[self addSublayer: [self effect]];
			
			dispatch_async(dispatch_get_main_queue(), ^(void)
			{
				[self _setupAnimationGroup];
				[[self effect] addAnimation: [self animationGroup] forKey: @"pulse"];
			});
		}
		return self;
	}

	- (void)setBackgroundColor: (CGColorRef)backgroundColor
	{
		[super setBackgroundColor: backgroundColor];
		[[self effect] setBackgroundColor: backgroundColor];
	}

	- (void)setRadius: (CGFloat)radius
	{
		[[self effect] setBounds: CGRectMake(0, 0, 2 * radius, 2 * radius)];
		[[self effect] setCornerRadius: radius];
	}

	- (void)_setupAnimationGroup
	{
		CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath: @"transform.scale.xy"];
		[scaleAnimation setDuration: 0.7];
		[scaleAnimation setFromValue: @0];
		[scaleAnimation setToValue: @1];
		
		CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath: @"opacity"];
		[opacityAnimation setDuration: 0.7];
		[opacityAnimation setFromValue: @1];
		[opacityAnimation setToValue: @0];

		[self setAnimationGroup: [CAAnimationGroup animation]];
		[[self animationGroup] setDuration: 0.7];
		[[self animationGroup] setTimingFunction: [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionDefault]];
		[[self animationGroup] setAnimations: @[scaleAnimation, opacityAnimation]];
	}

	@end

	%hook CKMessageEntryView

	- (void)setSendButton: (id)arg1
	{
		%orig;
		
		UILongPressGestureRecognizer *switchServiceGesture = [[UILongPressGestureRecognizer alloc] initWithTarget: self action: @selector(switchSendingServiceGesture:)];
		[switchServiceGesture setMinimumPressDuration: 0.5];
		[[self sendButton] addGestureRecognizer: switchServiceGesture];
	}

	%new
	- (void)switchSendingServiceGesture: (UILongPressGestureRecognizer*)gesture
	{
		if([gesture state] == UIGestureRecognizerStateBegan)
		{
			isIMessage = [[[self conversation] serviceDisplayName] isEqualToString: @"iMessage"];
			IMServiceImpl *serviceImpl = [%c(IMServiceImpl) serviceWithName: (isIMessage ? @"SMS" : @"iMessage")];
			[[[self conversation] chat] _targetToService: serviceImpl newComposition: !isIMessage];

			[self showPulse];
			produceHeavyVibration();
		}
	}

	%new
	- (void)showPulse
	{
		PulsingHaloLayer *halo = [[PulsingHaloLayer alloc] init];
		[halo setPosition: [self convertPoint: [[self sendButton] origin] toView: self]];
		[halo setRadius: [[self sendButton] frame].size.width * 5];
		[halo setBackgroundColor: isIMessage ? [UIColor systemGreenColor].CGColor : [UIColor systemBlueColor].CGColor];
		[[self layer] addSublayer: halo];
	}

	%end

%end

%ctor
{
	pref = [[HBPreferences alloc] initWithIdentifier: @"com.johnzaro.perfectmessages"];
	[pref registerDefaults:
	@{
		@"enabled": @NO,
		@"returnToMessagesOnClose": @NO,
		@"easySwitchIMessageSMS": @NO,
	}];

	enabled = [pref boolForKey: @"enabled"];
	if(enabled)
	{
		returnToMessagesOnClose = [pref boolForKey: @"returnToMessagesOnClose"];
		easySwitchIMessageSMS = [pref boolForKey: @"easySwitchIMessageSMS"];

		if(returnToMessagesOnClose)
			%init(returnToMessagesListOnCloseGroup);
		if(easySwitchIMessageSMS)
			%init(easySwitchIMessageSMSGroup);
	}
}