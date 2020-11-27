#import "CCModulesCustomSize.h"
#import "ControlCenterPreferences.h"

static ControlCenterPreferences *preferences;

// Original tweak by @andrewwiik: https://github.com/andrewwiik/BetterCCXI

static BOOL shouldEditMusicStyle = YES;

%group customConnectivitySizeGroup

	%hook CCUIConnectivityModuleViewController

	- (void)viewDidLayoutSubviews
	{
		%orig;

		if(![self isExpanded])
		{
			NSArray<UIViewController*> *viewControllers = nil;
			
			if([self _isPortrait])
				viewControllers = [self portraitButtonViewControllers];
			else 
				viewControllers = [self landscapeButtonViewControllers];

			if(viewControllers)
			{
				CGSize buttonSize = [self _compressedButtonSize];
				NSInteger rowCount = [preferences connectivityRows];
				NSInteger columnCount = [preferences connectivityColumns];
				CGFloat horizontalSpacing = ([[self view] bounds].size.width - (buttonSize.width * columnCount)) / (2 + (columnCount - 1));
				CGFloat verticalSpacing = ([[self view] bounds].size.height - (buttonSize.height * rowCount)) / (2 + (rowCount - 1));
				NSInteger maxButtonShow = MIN([viewControllers count], rowCount * columnCount);
				BOOL shouldBreak = NO;

				for(NSInteger row = 0; row < rowCount; row++)
				{
					for(NSInteger column = 0; column < columnCount; column++)
					{
						NSInteger index = row * columnCount + column;
						if(index < maxButtonShow)
						{
							CGRect frame = CGRectMake(horizontalSpacing * (1 + column) + column * buttonSize.width, verticalSpacing * (1 + row) + row * buttonSize.height, 0, 0);
							frame.size = buttonSize;

							UIView *buttonView = [((UIViewController*)[viewControllers objectAtIndex: index]) view];
							if(buttonView)
							{
								[buttonView setAlpha: 1.0];
								[buttonView setFrame: frame];
							}
						}
						else
						{
							shouldBreak = YES;
							break;
						}
					}
					if(shouldBreak)
						break;
				}
			}
		}
	}

	%end

%end

%group musicGroup

	%hook MediaControlsEndpointsViewController

	- (void)_adjustForEnvironmentChangeWithSize: (CGSize)size transitionCoordinator: (id)coordinator
	{
		NSArray<UIViewController*> *controllers = [self childViewControllers];
		if(controllers && [controllers count] > 0 && [controllers[0] isKindOfClass: %c(MRPlatterViewController)])
			[(MRPlatterViewController*)controllers[0] setIsOnControlCenter: YES];

		if(size.height < [self preferredExpandedContentHeight])
			shouldEditMusicStyle = YES;
		else
			shouldEditMusicStyle = NO;

		%orig;
	}

	- (void)_updateFramesForActiveViewControllersWithCoordinator: (id)coordinator assumingSize: (CGSize)size
	{
		if(size.height < [self preferredExpandedContentHeight])
			[self setDisplayMode: 0];

		%orig;
	}

	- (void)_transitionToDisplayMode: (NSInteger)arg2 usingTransitionCoordinator: (id)arg3 assumingSize: (CGSize)arg4
	{
		if(shouldEditMusicStyle)
			%orig(0, arg3, arg4);
		else
			%orig;
	}

	- (void)viewWillAppear: (BOOL)willAppear
	{
		%orig;

		MRPlatterViewController *platterViewController;
		NSArray<UIViewController*> *controllers = [self childViewControllers];
		if(controllers && [controllers count] > 0 && [controllers[0] isKindOfClass: %c(MRPlatterViewController)])
		{
			platterViewController = (MRPlatterViewController*)controllers[0];
			[platterViewController setIsOnControlCenter: YES];
		}

		CGSize size = [[self view] bounds].size;
		if(size.height < [self preferredExpandedContentHeight])
			[self setDisplayMode: 0];

		[self _adjustForEnvironmentChangeWithSize: size transitionCoordinator: nil];
		[self viewWillTransitionToSize: [[self view] bounds].size];
		[self _updateContentSize];

		if(platterViewController)
		{
			[platterViewController setStyle: 1];
			[platterViewController _updateStyle];
		}
	}

	%end

	%hook MRPlatterViewController

	- (void)setStyle: (NSInteger)style
	{
		if([self isOnControlCenter])
		{
			[[self nowPlayingHeaderView] setIsOnControlCenter: YES];
			[[[self parentContainerView] containerView] setIsOnControlCenter: YES];
			
			if(shouldEditMusicStyle)
				%orig(1);
			else
				%orig;
		}
		else
			%orig;
	}

	- (void)viewDidLayoutSubviews
	{
		%orig;

		if([self isOnControlCenter] && shouldEditMusicStyle)
		{
			[[self nowPlayingHeaderView] setFrame: CGRectMake(-7, 15, self.view.bounds.size.width + 7, [[[self nowPlayingHeaderView] artworkBackground] frame].size.height)];
			[[self parentContainerView] setFrame: CGRectMake(0, [[self nowPlayingHeaderView] frame].origin.y + [[self nowPlayingHeaderView] frame].size.height, [[self view] bounds].size.width, [[self view] bounds].size.height - ([[self nowPlayingHeaderView] frame].size.height + [[self nowPlayingHeaderView] frame].origin.y))];
		}
	}

	%new
	- (BOOL)isOnControlCenter
	{
    	return [objc_getAssociatedObject(self, @selector(isOnControlCenter)) isEqual: @YES] ? YES : NO;
	}

	%new
	- (void)setIsOnControlCenter: (BOOL)value
	{
    	objc_setAssociatedObject(self, @selector(isOnControlCenter), @(value), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}

	%end

	%hook MediaControlsHeaderView

	- (void)setStyle: (NSInteger)style
	{
		if([self isOnControlCenter])
		{
			if(shouldEditMusicStyle)
				%orig(2);
			else
				%orig(0);
		}
		else 
			%orig;
	}

	- (void)setSecondaryString: (NSString*)string
	{
		if([self isOnControlCenter] && shouldEditMusicStyle)
			MSHookIvar<NSInteger>([self _viewControllerForAncestor], "_style") = 1;

		%orig;
	}

	- (void)layoutSubviews
	{
		%orig;

		if([self isOnControlCenter])
		{
			MediaControlsContainerView *containerView = [[(MRPlatterViewController*)[self _viewControllerForAncestor] parentContainerView] containerView];
			if(shouldEditMusicStyle)
			{
				[[self routeLabel] setAlpha: 0];

				UIVisualEffectView *primaryVisualEffectView = [containerView primaryVisualEffectView];
				if([primaryVisualEffectView superview] != self)
					[self addSubview: primaryVisualEffectView];
				UIView *viewToUse = [self primaryMarqueeView];
				if([self secondaryString] && [[self secondaryString] length] > 0)
					viewToUse = [self secondaryMarqueeView];
				[primaryVisualEffectView setFrame: CGRectMake([[self primaryMarqueeView] frame].origin.x, [viewToUse frame].origin.y + [viewToUse frame].size.height, [self frame].size.width - (15 + [[self primaryMarqueeView] frame].origin.x), 34)];
				[primaryVisualEffectView setAlpha: 1];

				MediaControlsTimeControl *timeControl = [containerView timeControl];
				[timeControl setTimeControlOnScreen: YES];
				CGRect timeControlFrame = [primaryVisualEffectView bounds];
				timeControlFrame.origin.y = -20;
				timeControlFrame.size.height = 54;
				[timeControl setFrame: timeControlFrame];
				[timeControl setAlpha: 1];
			}
		}
	}

	- (void)_updateStyle
	{
		%orig;

		if([self isOnControlCenter])
		{
			if(shouldEditMusicStyle)
			{
				[[self routeLabel] setHidden: YES];

				[[self routeLabel] setAlpha: 0];
			
				[[self secondaryMarqueeView] setAlpha: 0.75];
				[[self secondaryMarqueeView] setTransform: CGAffineTransformMakeScale(0.8, 0.8)];
				[[[self secondaryMarqueeView] layer] setAnchorPoint: CGPointMake(0, 0)];
			}
			else
			{
				[[self routeLabel] setHidden: NO];

				[[self secondaryMarqueeView] setTransform: CGAffineTransformIdentity];
				[[[self secondaryMarqueeView] layer] setAnchorPoint: CGPointMake(0.5, 0.5)];
			}
		}
	}

	- (CGSize)layoutTextInAvailableBounds: (CGRect)arg2 setFrames: (BOOL)arg3 
	{
		CGSize result = %orig;

		if([self isOnControlCenter] && shouldEditMusicStyle) 
		{
			CGRect titleFrame = [[self routeLabel] frame];

			[[self launchNowPlayingAppButton] setHidden: NO];

			CGRect primaryFrame = [[self primaryMarqueeView] frame];
			CGRect secondaryFrame = [[self secondaryMarqueeView] frame];
			primaryFrame.origin = titleFrame.origin;
			primaryFrame.origin.y = [[self artworkView] frame].origin.y;

			secondaryFrame.origin.y = titleFrame.origin.y + primaryFrame.size.height - 4;
			[[self primaryMarqueeView] setFrame: primaryFrame];
			[[self secondaryMarqueeView] setFrame: secondaryFrame];

			MRPlatterViewController *controller = (MRPlatterViewController*)[self _viewControllerForAncestor];
			UIVisualEffectView *primaryVisualEffectView = [[[controller parentContainerView] containerView] primaryVisualEffectView];
			MediaControlsTimeControl *timeControl =  [[[controller parentContainerView] containerView] timeControl];

			if(primaryVisualEffectView) 
			{
				UIView *viewToUse = [self primaryMarqueeView];
				if([self secondaryString] && [[self secondaryString] length] > 0) 
					viewToUse = [self secondaryMarqueeView];
				CGFloat xOrigin = [[self primaryMarqueeView] frame].origin.x;
				CGFloat width = [self frame].size.width - (15 + [[self primaryMarqueeView] frame].origin.x);
				[primaryVisualEffectView setFrame: CGRectMake(xOrigin, [viewToUse frame].origin.y + [viewToUse frame].size.height, width, 34)];
				[primaryVisualEffectView setAlpha: 1];
			}

			if(timeControl && primaryVisualEffectView) 
			{
				CGRect timeControlFrame = [primaryVisualEffectView bounds];
				timeControlFrame.origin.y = -20;
				timeControlFrame.size.height = 54;
				[timeControl setFrame: timeControlFrame];
				[timeControl setAlpha: 1];
			}
		}
		return result;
	}

	%new
	- (BOOL)isOnControlCenter
	{
    	return [objc_getAssociatedObject(self, @selector(isOnControlCenter)) isEqual: @YES] ? YES : NO;
	}

	%new
	- (void)setIsOnControlCenter: (BOOL)value
	{
    	objc_setAssociatedObject(self, @selector(isOnControlCenter), @(value), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}

	%end

	%hook MediaControlsContainerView

	- (void)layoutSubviews // helps with setting correct position to timeControl when moving from compact -> expanded 
	{
		if([self isOnControlCenter])
		{
			[[self timeControl] setIsOnControlCenter: YES];
			if(!shouldEditMusicStyle && [self primaryVisualEffectView] && [[self primaryVisualEffectView] superview] != self)
			{
				[self addSubview: [self primaryVisualEffectView]];
				[self sendSubviewToBack: [self primaryVisualEffectView]];
			}
		}

		%orig;
	}

	%new
	- (BOOL)isOnControlCenter
	{
    	return [objc_getAssociatedObject(self, @selector(isOnControlCenter)) isEqual: @YES] ? YES : NO;
	}

	%new
	- (void)setIsOnControlCenter: (BOOL)value
	{
    	objc_setAssociatedObject(self, @selector(isOnControlCenter), @(value), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}

	%end

	%hook MediaControlsTimeControl

	- (void)updateLabelAvoidance // do not move down time labels when scrolling time control in compact mode
	{
		if([self isOnControlCenter] && shouldEditMusicStyle)
			return;
		else
			%orig;
	}

	%new
	- (BOOL)isOnControlCenter
	{
    	return [objc_getAssociatedObject(self, @selector(isOnControlCenter)) isEqual: @YES] ? YES : NO;
	}

	%new
	- (void)setIsOnControlCenter: (BOOL)value
	{
    	objc_setAssociatedObject(self, @selector(isOnControlCenter), @(value), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}

	%end

%end

%group customModulesSizeGroup

	%hook CCUIModuleSettingsManager

	- (id)moduleSettingsForModuleIdentifier: (NSString*)identifier prototypeSize: (CCUILayoutSize)protoSize
	{
		CCUILayoutSize layoutSize;
		if(identifier)
		{
			if([identifier isEqualToString: @"com.apple.control-center.ConnectivityModule"] && [preferences customConnectivitySizeEnabled])
				layoutSize = CCUILayoutSizeMake([preferences connectivityColumns], [preferences connectivityRows]);
			if([identifier isEqualToString: @"com.apple.mediaremote.controlcenter.nowplaying"] && [preferences customMusicSizeEnabled])
			{
				if([preferences musicSize] == 1)
					layoutSize = CCUILayoutSizeMake(3, 2);
				else if([preferences musicSize] == 2)
					layoutSize = CCUILayoutSizeMake(4, 2);
			}
		}
		if(layoutSize.width != 0)
			return [[%c(CCUIModuleSettings) alloc] initWithPortraitLayoutSize: layoutSize landscapeLayoutSize: layoutSize];
		else
			return %orig;
	}

	%end

%end

static void notificationCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
	if([((__bridge NSDictionary*)userInfo)[NSLoadedClasses] containsObject: @"CCUIConnectivityModuleViewController"])
		%init(customConnectivitySizeGroup);
}

void initCCModulesCustomSize()
{
	@autoreleasepool
	{
		preferences = [ControlCenterPreferences sharedInstance];

		if([preferences customConnectivitySizeEnabled])
			CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(), NULL, notificationCallback, (CFStringRef)NSBundleDidLoadNotification, NULL, CFNotificationSuspensionBehaviorCoalesce);
		
		if([preferences customMusicSizeEnabled])
			%init(musicGroup);
		
		%init(customModulesSizeGroup);
	}
}