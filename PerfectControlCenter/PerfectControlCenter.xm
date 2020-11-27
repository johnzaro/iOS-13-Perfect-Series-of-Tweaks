#import "PerfectControlCenter.h"
#import "ControlCenterPreferences.h"

static ControlCenterPreferences *preferences;

static CGRect originalControlCenterStatusBarFrame;
static BOOL validOriginalControlCenterStatusBarFrame;

static BOOL bluetoothEnabled;

#if __cplusplus
    extern "C" {
#endif
  extern CGFloat MediaControlsMaxWidthOfCondensedModule;
#if __cplusplus
}
#endif

// MAKE CONTROL CENTER TOGGLES ROUND

%group roundCCModulesGroup

	%hook CCUIContentModuleContentContainerView

	- (void)layoutSubviews
	{
		%orig;

		BOOL tvModule = NO;
		for(UIView *subview in [self subviews])
		{
			if([[subview _viewControllerForAncestor] isKindOfClass: %c(TVRMContentViewController)])
			{
				tvModule = YES;
				break;
			}
		}

		BOOL expanded = MSHookIvar<BOOL>(self, "_expanded");
		int radius = expanded ? 65 : 34;
		int numberOfSelfSubviews = [[self subviews] count];
		
		if(!tvModule || !expanded)
		{
			[self setClipsToBounds: YES];
			[[self layer] setCornerRadius: radius];
		}

		if(numberOfSelfSubviews == 1)
		{
			UIView *subview1 = [self subviews][0];
			if([[subview1 subviews] count] >= 1)
			{
				UIView *subview2 = [subview1 subviews][0];
				if([subview2 isKindOfClass: %c(MediaControlsVolumeSliderView)])
				{
					[subview2 setClipsToBounds: YES];
					[[subview2 layer] setCornerRadius: radius];
				}
				else
				{
					if([[subview2 subviews] count] > 0)
					{
						UIView *subview3 = [subview2 subviews][0];
						if([[subview3 subviews] count] > 0)
						{
							UIView *subview4 = [subview3 subviews][0];
							if([[subview4 subviews] count] > 0)
							{
								UIView *subview5 = [subview4 subviews][0];
								if([subview5 isKindOfClass: %c(MTMaterialView)])
									[[subview5 layer] setCornerRadius: radius];
							}
						}
					}
				}
			}
		}
		else if(numberOfSelfSubviews > 1)
		{
			UIView *subview = [self subviews][1];
			if([subview isKindOfClass: %c(CCUIContinuousSliderView)])
				[[subview layer] setCornerRadius: radius];
		}
	}

	%end

%end

// SHOW PERCENTAGE ON CONTROL CENTER SLIDERS

// Original Tweak by @baptistecdr: https://github.com/baptistecdr/SugarCane

%group showSliderPercentageGroup

	%hook CCUIBaseSliderView

	%property(nonatomic, retain) UILabel *percentLabel;

	- (id)initWithFrame: (CGRect)frame
	{
		self = %orig;

		[self setPercentLabel: [[UILabel alloc] init]];
		[[self percentLabel] setFont: [UIFont systemFontOfSize: 15]];
		
		return self;
	}

	- (void)layoutSubviews
	{
		%orig;

		UIView *glyphView = (UIView*)[self valueForKey: @"_glyphPackageView"];
		if([[self percentLabel] superview] != glyphView)
		{
			if([[self percentLabel] superview])
				[[self percentLabel] removeFromSuperview];
			[glyphView addSubview: [self percentLabel]];
		}

		[[self percentLabel] setText: [NSString stringWithFormat: @"%.0f%%", [self value] * 100]];
		[[self percentLabel] sizeToFit];
		[[self percentLabel] setCenter: [self convertPoint: CGPointMake([self bounds].size.width * 0.5, [self bounds].size.height * 0.5) toView: glyphView]];
	}

	%end

%end

// HIDE STATUS BAR ON CONTROL CENTER

%group hideControlCenterStatusBarGroup

	%hook CCUIModularControlCenterOverlayViewController

	- (CCUIHeaderPocketView*)overlayHeaderView
	{
		return nil;
	}

	%end

%end

// MOVE CONTROL CENTER TO THE BOTTOM OF THE SCREEN

// Original Tweak by @himynameisubik: https://github.com/himynameisubik/StayLowCC

%group moveControlCenterToTheBottomGroup

	%hook CCUIModularControlCenterOverlayViewController

	- (void)presentAnimated: (BOOL)arg1 withCompletionHandler: (/*^block*/id)arg2
	{
		%orig;
		[self moveToBottom];
	}

	- (void)dismissAnimated: (BOOL)arg1 withCompletionHandler: (/*^block*/id)arg2
	{
		if(![preferences hideControlCenterStatusBar])
			[self fixStatusBarOnDismiss];
		%orig;
	}

	%new
	- (void)fixStatusBarOnDismiss
	{
		if(validOriginalControlCenterStatusBarFrame)
		{
			[[self overlayHeaderView] setFrame: originalControlCenterStatusBarFrame];
			validOriginalControlCenterStatusBarFrame = NO;
		}
	}

	%new
	- (void)moveToBottom
	{
		if([self overlayInterfaceOrientation] == 1)
		{
			CGRect overlayContainerViewFrame = [[self overlayContainerView] frame];
			overlayContainerViewFrame.origin.y = 
				[[self overlayScrollView] frame].size.height - [[self overlayContainerView] frame].size.height - 124;
			[[self overlayContainerView] setFrame: overlayContainerViewFrame];

			if(![preferences hideControlCenterStatusBar])
			{
				if(!validOriginalControlCenterStatusBarFrame)
				{
					originalControlCenterStatusBarFrame = [[self overlayHeaderView] frame];
					validOriginalControlCenterStatusBarFrame = YES;
				}
				CGRect overlayHeaderViewFrame = [[self overlayHeaderView] frame];
				overlayHeaderViewFrame.origin.y = 
					[[self overlayScrollView] frame].size.height - [[self overlayContainerView] frame].size.height 
					- [[self overlayHeaderView] frame].size.height - 20;
				[[self overlayHeaderView] setFrame: overlayHeaderViewFrame];
			}
		}
	}

	%end

%end

%group turnOffOnTapGroup

	// Original tweak by @jakeajames: https://github.com/jakeajames/RealCC

	%hook CCUILabeledRoundButton

	- (void)buttonTapped: (id)arg1
	{
		%orig;

		if([self.title isEqualToString: [[NSBundle bundleWithPath: @"/System/Library/ControlCenter/Bundles/ConnectivityModule.bundle"] localizedStringForKey: @"CONTROL_CENTER_STATUS_WIFI_NAME" value: @"CONTROL_CENTER_STATUS_WIFI_NAME" table: @"Localizable"]] 
		|| [self.title isEqualToString: [[NSBundle bundleWithPath: @"/System/Library/ControlCenter/Bundles/ConnectivityModule.bundle"] localizedStringForKey: @"CONTROL_CENTER_STATUS_WLAN_NAME" value: @"CONTROL_CENTER_STATUS_WLAN_NAME" table: @"Localizable"]])
		{
			SBWiFiManager *wifiManager = (SBWiFiManager*)[%c(SBWiFiManager) sharedInstance];
			if([wifiManager wiFiEnabled])
				[wifiManager setWiFiEnabled: NO];
		}

		if([self.title isEqualToString: [[NSBundle bundleWithPath: @"/System/Library/ControlCenter/Bundles/ConnectivityModule.bundle"] localizedStringForKey: @"CONTROL_CENTER_STATUS_BLUETOOTH_NAME" value: @"CONTROL_CENTER_STATUS_BLUETOOTH_NAME" table: @"Localizable"]])
		{
			BluetoothManager *bluetoothManager = (BluetoothManager*)[%c(BluetoothManager) sharedInstance];
			BOOL enabled = [bluetoothManager enabled];

			if(enabled)
			{
				[bluetoothManager setEnabled: NO];
				[bluetoothManager setPowered: NO];

				bluetoothEnabled = NO;
			}
			else
				bluetoothEnabled = YES;
		}
	}

	%end

	%hook BluetoothManager

	-(BOOL)enabled
	{
		bluetoothEnabled = !%orig;
		return %orig;
	}

	- (BOOL)setEnabled: (BOOL)arg1
	{
		return %orig(bluetoothEnabled);
	}

	- (BOOL)setPowered: (BOOL)arg1
	{
		return %orig(bluetoothEnabled);
	}

	%end

%end

void initPerfectControlCenter()
{
	@autoreleasepool
	{
		preferences = [ControlCenterPreferences sharedInstance];
		
		if([preferences roundCCModules])
			%init(roundCCModulesGroup);
		if([preferences showSliderPercentage])
			%init(showSliderPercentageGroup);
		if([preferences hideControlCenterStatusBar])
			%init(hideControlCenterStatusBarGroup);
		if([preferences moveControlCenterToTheBottom] && ![preferences isIpad])
			%init(moveControlCenterToTheBottomGroup);
		if([preferences turnOffOnTap])
			%init(turnOffOnTapGroup);
	}
}