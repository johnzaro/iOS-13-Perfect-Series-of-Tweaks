// Copyright (c) 2017-2020 Lars Fröder

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#import <objc/runtime.h>
#import "PerfectSafari.h"
#import "SafariPreferences.h"
#import "SparkColourPickerUtils.h"

static SafariPreferences *preferences;

static UIColor *selectedColor;

extern "C"
{
	id objc_msgSendSuper2(struct objc_super *super, SEL op, ...);
}

// ----------------------------------------------------------------
// --------------------------- METHODS ----------------------------
// ----------------------------------------------------------------

void configureBarButtonItem(UIBarButtonItem* item, NSString* accessibilityIdentifier, NSString* title, id target, SEL longPressAction, SEL touchDownAction)
{
	[item setAccessibilityIdentifier: accessibilityIdentifier];
	[item setTitle: title];
	if(touchDownAction) [item _sf_setTarget: target touchDownAction: touchDownAction longPressAction: longPressAction];
	else [item _sf_setTarget: target longPressAction: longPressAction];
}

// ----------------------------------------------------------------
// ---------------------------- HOOKS -----------------------------
// ----------------------------------------------------------------

// Colorize Safari

%group colorizeGroup

	%hook _SFNavigationBar

	- (void)setTheme: (_SFBarTheme*)theme
	{
		_SFBarTheme* themeCopy = [%c(_SFBarTheme) themeWithTheme: theme];
		[themeCopy setValue: selectedColor forKey: @"_preferredControlsTintColor"];
		%orig(themeCopy);
	}

	- (void)_didUpdateEffectiveTheme
	{
		[[self effectiveTheme] setValue: selectedColor forKey: @"_textColor"];
		[[self effectiveTheme] setValue: selectedColor forKey: @"_secureTextColor"];
		[[self effectiveTheme] setValue: selectedColor forKey: @"_warningTextColor"];
		[[self effectiveTheme] setValue: selectedColor forKey: @"_platterTextColor"];
		[[self effectiveTheme] setValue: selectedColor forKey: @"_platterSecureTextColor"];
		[[self effectiveTheme] setValue: selectedColor forKey: @"_platterWarningTextColor"];
		[[self effectiveTheme] setValue: selectedColor forKey: @"_platterAnnotationTextColor"];
		[[self effectiveTheme] setValue: selectedColor forKey: @"_platterProgressBarTintColor"];
		[[self effectiveTheme] setValue: [selectedColor colorWithAlphaComponent: 0.5] forKey: @"_platterPlaceholderTextColor"];

		%orig;
	}

	%end

	%hook _SFToolbar

	- (void)setTheme: (_SFBarTheme*)theme
	{
		_SFBarTheme* themeToUse = [%c(_SFBarTheme) themeWithTheme: theme];
		[themeToUse setValue: selectedColor forKey: @"_controlsTintColor"];
		%orig(themeToUse);
	}

	%end

	%hook TabBarItemView

	- (void)setActive: (BOOL)active
	{
		%orig;

		[UIView performWithoutAnimation:
		^{
			if(active) [(UILabel*)[self valueForKey: @"_titleLabel"] setAlpha: 1.0];
			else [(UILabel*)[self valueForKey: @"_titleLabel"] setAlpha: 0.8];

			[(UIVisualEffectView*)[self valueForKey: @"_contentEffectsView"] setEffect: nil];
		}];
	}

	- (void)updateTabBarStyle
	{
		%orig;

		dispatch_async(dispatch_get_main_queue(), 
		^{
			[(UILabel*)[self valueForKey: @"_titleLabel"] setTextColor: selectedColor];
			[(UIVisualEffectView*)[self valueForKey: @"_contentEffectsView"] setEffect: nil];
			[(UIVisualEffectView*)[self valueForKey: @"_closeButtonEffectsView"] setEffect: nil];
			[(UIButton*)[self valueForKey: @"_closeButton"] setTintColor: selectedColor];
		});
	}

	%end

%end

// Show full URL in NavBar

%group showFullURLGroup

	%hook _SFNavigationBarItem

	- (void)setText: (NSString*)text textWhenExpanded: (NSString*)textWhenExpanded startIndex: (NSUInteger)startIndex
	{
		%orig(textWhenExpanded, textWhenExpanded, startIndex);
	}

	%end

%end

// Add 'New Tab' button to bottom bar

%group addNewTabButtonGroup

	%hook SFBarRegistration

	- (instancetype)initWithBar: (_SFToolbar*)bar barManager: (id)barManager layout: (NSInteger)layout persona: (NSUInteger)persona
	{
		if(persona == 0 && layout == 2)
		{
			objc_super super;
			super.receiver = self;
			super.super_class = [self class];

			self = objc_msgSendSuper2(&super, @selector(init));

			[self setValue: bar forKey: @"_bar"];
			[self setValue: barManager forKey: @"_barManager"];
			[self setValue: @(layout) forKey: @"_layout"];

			NSMutableArray* barButtonItems = [NSMutableArray new];
			[barButtonItems addObject: @0];
			[barButtonItems addObject: @1];
			[barButtonItems addObject: @3];
			[barButtonItems addObject: @2];
			[barButtonItems addObject: @4];
			[barButtonItems addObject: @5];

			[self setValue: [NSOrderedSet orderedSetWithArray: [barButtonItems copy]] forKey: @"_arrangedBarItems"];
			[self setValue: [[NSMutableSet alloc] init] forKey: @"_hiddenBarItems"];

			// 0: back 1: forward 2: bookmarks 3: share 4: add tab 5: tabs

			UIBarButtonItem* backItem = [self _newBarButtonItemForSFBarItem: 0];
			configureBarButtonItem(backItem, @"BackButton", @"Back (toolbar accessibility title)", self, @selector(_itemReceivedLongPress:), nil);
			[self setValue: backItem forKey: @"_backItem"];

			UIBarButtonItem* forwardItem = [self _newBarButtonItemForSFBarItem: 1];
			configureBarButtonItem(forwardItem, @"ForwardButton", @"Forward (toolbar accessibility title)", self, @selector(_itemReceivedLongPress:), nil);
			[self setValue: forwardItem forKey: @"_forwardItem"];

			UIBarButtonItem* bookmarksItem = [self _newBarButtonItemForSFBarItem: 2];
			configureBarButtonItem(bookmarksItem, @"BookmarksButton", @"Bookmarks (toolbar accessibility title)", self, @selector(_itemReceivedLongPress:), nil);
			bookmarksItem._additionalSelectionInsets = UIEdgeInsetsMake(2, 0, 3, 0);
			[self setValue: bookmarksItem forKey: @"_bookmarksItem"];

			UIBarButtonItem* shareItem = [self _newBarButtonItemForSFBarItem: 3];
			configureBarButtonItem(shareItem, @"ShareButton", @"Share (toolbar accessibility title)", self, @selector(_itemReceivedLongPress:), @selector(_itemReceivedTouchDown:));
			[self setValue: shareItem forKey: @"_shareItem"];

			UIBarButtonItem* newTabItem = [self _newBarButtonItemForSFBarItem: 4];
			configureBarButtonItem(newTabItem, @"NewTabButton", @"New Tab (toolbar accessibility title)", self, @selector(_itemReceivedLongPress:), nil);
			[self setValue: newTabItem forKey: @"_newTabItem"];

			UIBarButtonItem* tabExposeItem = [self _newBarButtonItemForSFBarItem: 5];
			configureBarButtonItem(tabExposeItem, @"TabsButton", @"Tabs (toolbar accessibility title)", self, @selector(_itemReceivedLongPress:), nil);
			[self setValue: tabExposeItem forKey: @"_tabExposeItem"];

			return self;
		}
		else
			return %orig;
	}

	%end

%end

// Show open tabs count

%group showOpenTabsCountGroup

	%hook _SFToolbar

	%property (nonatomic,retain) UILabel *tabCountLabel;
	%property (nonatomic,retain) UIImage *tabExposeImage;
	%property (nonatomic,retain) UIImage *tabExposeImageWithCount;

	- (instancetype)initWithPlacement: (NSInteger)placement
	{
		self = %orig;

		[self setTabCountLabel: [[UILabel alloc] init]];
		[[self tabCountLabel] setAdjustsFontSizeToFitWidth: YES];
		[[self tabCountLabel] setNumberOfLines: 1];
		[[self tabCountLabel] setBaselineAdjustment: UIBaselineAdjustmentAlignCenters];
		[[self tabCountLabel] setTextAlignment: NSTextAlignmentCenter];
		[[self tabCountLabel] setTextColor: [UIColor blackColor]];
		
		if([UIScreen mainScreen].scale >= 3)
			[[self tabCountLabel] setFrame: CGRectMake(9, 7.66, 13, 13)];
		else
			[[self tabCountLabel] setFrame: CGRectMake(9, 8, 13, 13)];

		return self;
	}

	- (void)layoutSubviews
	{
		%orig;

		if([self tabCountLabel])
			[self updateTabCount];
	}

	%new
	- (void)updateTabCount
	{
		if([self tabCountLabel])
		{
			dispatch_async(dispatch_get_main_queue(),
			^{
				SFBarRegistration *barRegistration = MSHookIvar<SFBarRegistration*>(self, "_barRegistration");
				UIBarButtonItem *tabExposeItem = [barRegistration UIBarButtonItemForItem: 5];

				//Adding the label as a subview causes issues so we have to directly modify the image!

				//Save the original image if we don't have it already
				if(![self tabExposeImage])
					[self setTabExposeImage: [tabExposeItem image]];

				TabController* tabController = [[MSHookIvar<_SFBarManager*>(MSHookIvar<SFBarRegistration*>(self, "_barRegistration"), "_barManager") delegate] tabController];

				NSUInteger newTabCount = [tabController numberOfCurrentNonHiddenTabs];
				if(newTabCount == 0)
					newTabCount = 1;

				NSString *newText = [NSString stringWithFormat: @"%llu", (unsigned long long)newTabCount];

				if(![[[self tabCountLabel] text] isEqualToString: newText]) //If label changed, update image
				{
					[[self tabCountLabel] setText: newText];

					//Convert label to image
					UIGraphicsBeginImageContextWithOptions([self tabExposeImage].size, NO, 0.0);
					[[[self tabCountLabel] layer] renderInContext: UIGraphicsGetCurrentContext()];
					UIImage *labelImg = UIGraphicsGetImageFromCurrentImageContext();
					UIGraphicsEndImageContext();

					//Add labelImage to buttonImage
					UIGraphicsBeginImageContextWithOptions([self tabExposeImage].size, NO, 0.0);
					CGRect rect = CGRectMake(0, 0, [self tabExposeImage].size.width, [self tabExposeImage].size.height);
					[[self tabExposeImage] drawInRect: rect];
					[labelImg drawInRect: CGRectMake([[self tabCountLabel] frame].origin.x, [[self tabCountLabel] frame].origin.y, [self tabExposeImage].size.width, [self tabExposeImage].size.height)];
					[self setTabExposeImageWithCount: UIGraphicsGetImageFromCurrentImageContext()];
					UIGraphicsEndImageContext();
				}

				[tabExposeItem setImage: [self tabExposeImageWithCount]]; //Apply image with count
			});
		}
	}

	%end

	%hook BrowserController

	- (void)tabControllerDocumentCountDidChange: (TabController*)tabController
	{
		%orig;
		[[[self rootViewController] bottomToolbar] updateTabCount];
	}

	- (void)setPrivateBrowsingEnabled: (BOOL)arg1
	{
		%orig;
		[[[self rootViewController] bottomToolbar] updateTabCount];
	}

	%end

	%hook TabController

	- (void)_restorePersistentDocumentState: (id)arg1 into: (id)arg2 withCurrentActiveDocument: (id)arg3 activeDocumentIsValid: (BOOL)arg4 restoredActiveDocumentIndex: (NSUInteger)arg5
	{
		%orig;
		[[[MSHookIvar<BrowserController*>(self, "_browserController") rootViewController] bottomToolbar] updateTabCount];
	}

	%end

%end

void initSafariPlusFeatures()
{
	@autoreleasepool
	{
		preferences = [SafariPreferences sharedInstance];

		if([preferences colorize])
		{
			NSDictionary *preferencesDictionary = [NSDictionary dictionaryWithContentsOfFile: @"/var/mobile/Library/Preferences/com.johnzaro.perfectsafariprefs.colors.plist"];
			selectedColor = [SparkColourPickerUtils colourWithString: [preferencesDictionary objectForKey: @"selectedColor"] withFallback: @"#FF9400"];
			
			%init(colorizeGroup);
		}
		if([preferences showFullURL]) %init(showFullURLGroup);
		if([preferences addNewTabButton] && ![preferences isIpad]) %init(addNewTabButtonGroup);
		if([preferences showOpenTabsCount]) %init(showOpenTabsCountGroup);
	}
}
