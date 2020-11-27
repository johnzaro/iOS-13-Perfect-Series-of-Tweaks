#import "PerfectHomeScreen.h"
#import <Cephei/HBPreferences.h>
#import "SparkAppList.h"
#import "SparkColourPickerUtils.h"

#define IS_iPAD ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

static HBPreferences *pref;
static BOOL enabled;
static BOOL disableParallaxEffect;
static BOOL progressBarWhenDownloading;
static BOOL enableCustomProgressBarColor;
static UIColor *customProgressBarColor;
static BOOL enableCustomDockRadius;
static NSUInteger dockCornerRadius;
static BOOL hideFolderTitle;
static BOOL folderTitleBold;
static BOOL enableCustomFolderTitleColor;
static UIColor *customFolderTitleColor;
static BOOL enableFolderTitleCustomFontSize;
static NSUInteger folderTitleCustomFontSize;
static BOOL autoCloseFolders;
static BOOL pinchToCloseFolder;
static BOOL enableCustomFolderIconBackgroundColor;
static UIColor *customFolderIconBackgroundColor;
static BOOL enableCustomFolderCornerRadius;
static NSUInteger folderCornerRadius;
static BOOL enableCustomFolderBackgroundColor;
static UIColor *customFolderBackgroundColor;
static BOOL customCornerRadius;
static NSUInteger iconCornerRadius;
static BOOL hideAppIcons;
static BOOL hideAppLabels;
static BOOL hideBlueDot;
static BOOL hidePageDots;
static BOOL customBgTextColorEnable;
static BOOL customTextColorEnable;
static UIColor *customBgTextColor;
static UIColor *customTextColor;
static BOOL hideWidgetsIn3DTouch;
static BOOL hideShareAppShortcut;
static BOOL addGetBundleIDShortcut;
static BOOL enableHomeScreenRotation;
static BOOL customHomeScreenLayoutEnabled;
static BOOL customHomeScreenRowsEnabled;
static BOOL customHomeScreenColumnsEnabled;
static BOOL customFolderRowsEnabled;
static BOOL customFolderColumnsEnabled;
static BOOL customDockColumnsEnabled;
static NSUInteger customHomeScreenRows;
static NSUInteger customHomeScreenColumns;
static NSUInteger customFolderRows;
static NSUInteger customFolderColumns;
static NSUInteger customDockColumns;

// ------------------------------ DETAILED DOWNLOAD BAR WHILE DOWNLOADING APPS ------------------------------

// ORIGINAL TWEAK @shepgoba: https://github.com/shepgoba/DownloadBar13

%group progressBarWhenDownloadingGroup

	%hook SBIconProgressView

	%property (nonatomic, strong) UILabel *progressLabel;
	%property (nonatomic, strong) UIView *progressBar;

	- (void)setFrame: (CGRect)arg1
	{
		%orig;
		if (arg1.size.width != 0)
		{
			self.progressBar.frame = CGRectMake(0, self.frame.size.height * (1 - self.displayedFraction), self.frame.size.width, self.frame.size.height * self.displayedFraction);
			self.progressLabel.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2 + 18);
		}
	}

	- (id)initWithFrame: (CGRect)arg1
	{
		if ((self = %orig))
		{
			self.progressBar = [[UIView alloc] init];
			self.progressBar.backgroundColor = customProgressBarColor ? customProgressBarColor : [UIColor systemBlueColor];
			self.progressBar.layer.cornerRadius = 13;
			self.progressBar.alpha = 0.7;

			self.progressLabel = [[UILabel alloc] init];
			self.progressLabel.font = [UIFont boldSystemFontOfSize: 14];
			self.progressLabel.textAlignment = NSTextAlignmentCenter;
			self.progressLabel.textColor = [UIColor whiteColor];
			self.progressLabel.text = @"0%%";

			[self addSubview: self.progressBar];
			[self addSubview: self.progressLabel];
		}
		return self;
	}

	- (void)setDisplayedFraction: (double)arg1
	{
		%orig;

		self.progressLabel.text = [NSString stringWithFormat: @"%i%%", (int)(arg1 * 100)];
		[self.progressLabel sizeToFit];
	}

	- (void)_drawPieWithCenter: (CGPoint)arg1
	{
		self.progressBar.frame = CGRectMake(0, self.frame.size.height * (1 - self.displayedFraction), self.frame.size.width, self.frame.size.height * self.displayedFraction);
		self.progressLabel.center = CGPointMake(arg1.x, arg1.y + 18);
	}

	- (void)_drawOutgoingCircleWithCenter: (CGPoint)arg1
	{

	}

	- (void)_drawIncomingCircleWithCenter: (CGPoint)arg1
	{

	}

	%end

%end

// ------------------------------ HIDE FOLDER TITLE ------------------------------

%group hideFolderTitleGroup

	%hook SBFloatyFolderView

	- (BOOL)_showsTitle
	{
		return NO;
	}

	%end

%end

// ------------------------------ CUSTOM FOLDER TITLE FONT WEIGHT ------------------------------

%group folderTitleBoldGroup

	%hook SBFolderTitleTextField

	- (void)setFont: (UIFont*)font
	{
		if(enableFolderTitleCustomFontSize)
			%orig([UIFont boldSystemFontOfSize: folderTitleCustomFontSize]);
		else
			%orig([UIFont boldSystemFontOfSize: 36]);
	}

	%end

%end

// ------------------------------ CUSTOM FOLDER TITLE FONT SIZE ------------------------------

%group folderTitleCustomFontSizeGroup

	%hook SBFloatyFolderView

	- (double)_titleFontSize
	{
		return folderTitleCustomFontSize;
	}

	%end

%end

// ------------------------------ CUSTOM FOLDER TITLE COLOR ------------------------------

%group customFolderTitleColorGroup

	%hook SBFolderTitleTextField

	- (void)setTextColor: (UIColor*)color
	{
		%orig(customFolderTitleColor);
	}

	%end

%end

// ------------------------------ AUTO CLOSE FOLDERS ------------------------------

%group autoCloseFoldersGroup

	%hook SBHIconManager

	- (void)iconTapped: (id)arg1
	{
		if([self openedFolderController] && [[self openedFolderController] isOpen]) [[self openedFolderController] _closeFolderTimerFired];
		
		%orig;
	}

	%end

%end

// ------------------------------ PINCH TO CLOSE FOLDERS ------------------------------

%group pinchToCloseFolderGroup

	%hook SBFolderSettings

	- (BOOL)pinchToClose
	{
		return YES;
	}

	%end

	%hook SBHFolderSettings

	- (BOOL)pinchToClose
	{
		return YES;
	}

	%end

%end

// ------------------------------ CUSTOM FOLDER ICON BACKGROUND COLOR ------------------------------

%group customFolderIconBackgroundColorGroup

	%hook SBFolderIconImageView

	- (void)layoutSubviews
	{ 
		%orig;

		[[[self backgroundView] blurView] setHidden: YES];
		[[self backgroundView] setBackgroundColor: customFolderIconBackgroundColor];
	}

	%end

%end

// ------------------------------ CUSTOM FOLDER CORNER RADIUS ------------------------------

%group customFolderCornerRadiusGroup

	%hook SBFloatyFolderView

	- (void)setCornerRadius: (double)arg1
	{
		%orig(folderCornerRadius);
	}

	%end

	%hook SBHFloatyFolderVisualConfiguration

	- (CGFloat)continuousCornerRadius
	{
		return folderCornerRadius;
	}

	%end

%end

// ------------------------------ CUSTOM FOLDER BACKGROUND COLOR ------------------------------

%group customFolderBackgroundColorGroup

	%hook SBFolderBackgroundView

	- (void)layoutSubviews
	{
		%orig;
		
		[self setBackgroundColor: customFolderBackgroundColor];
		[[self subviews] makeObjectsPerformSelector: @selector(removeFromSuperview)];

		if(enableCustomFolderCornerRadius)
			[[self layer] setCornerRadius: folderCornerRadius];
		else
			[[self layer] setCornerRadius: 38];
	}

	%end

%end

// ------------------------------ HIDE APP ICONS ------------------------------

%group hideAppIconsGroup

// ORIGINAL TWEAK @menushka: https://github.com/menushka/HideYourApps

	%hook SBIconListModel

	- (id)insertIcon: (SBApplicationIcon*)icon atIndex: (unsigned long long*)arg2 options: (unsigned long long)arg3
	{
		if([SparkAppList doesIdentifier: @"com.johnzaro.perfecthomescreen13prefs.hiddenApps" andKey: @"hiddenApps" containBundleIdentifier: [icon applicationBundleID]])
			return nil;
		else return %orig;
	}

	- (BOOL)addIcon: (SBApplicationIcon*)icon asDirty: (BOOL)arg2
	{
		if([SparkAppList doesIdentifier: @"com.johnzaro.perfecthomescreen13prefs.hiddenApps" andKey: @"hiddenApps" containBundleIdentifier: [icon applicationBundleID]]) 
			return nil;
		else return %orig;
	}

	%end

%end

// ------------------------------ HIDE APP LABEL ------------------------------

%group hideAppLabelsGroup

	%hook SBIconLegibilityLabelView

	- (void)setHidden: (BOOL)arg1
	{
		%orig(YES);
	}

	%end

%end

// ------------------------------ HIDE UPDATED APP BLUE DOT ------------------------------

%group hideBlueDotGroup

	%hook SBIconView

	- (BOOL)allowsLabelAccessoryView
	{
		return NO;
	}

	%end

%end

// ------------------------------ CUSTOM CORNER RADIUS ------------------------------

// %group customCornerRadiusGroup

// 	%hook SBIconImageView

// 	- (id)initWithFrame:(CGRect)arg1
// 	{
// 		self = %orig;

// 		if(![self isKindOfClass: %c(SBFolderIconImageView)])
// 		{
// 			[[self layer] setCornerRadius: iconCornerRadius];
// 			[self setClipsToBounds: YES];
// 		}
// 		return self;
// 	}

// 	%end

// %end

// ------------------------------ HIDE WIDGETS IN 3D TOUCH ------------------------------

%group hideWidgetsIn3DTouchGroup

	%hook SBHIconViewContextMenuWrapperViewController

	- (void)viewWillAppear: (BOOL)arg1
	{
		[[self view] setHidden: YES];
	}

	%end

	%hook _UICutoutShadowView

	- (void)layoutSubviews
	{
		[self setHidden: YES];
	}

	%end

%end

// ------------------------------ HIDE SHARE OPTION IN 3D TOUCH MENU ------------------------------

%group hideShareAppShortcutGroup

	%hook SBIconView

	- (void)setApplicationShortcutItems: (NSArray*)arg1
	{
		NSMutableArray *newShortcuts = [[NSMutableArray alloc] init];
		for(SBSApplicationShortcutItem *shortcut in arg1)
		{
			if([shortcut.type isEqual: @"com.apple.springboardhome.application-shortcut-item.share"])
				continue;
			else [newShortcuts addObject: shortcut];
		}

		%orig(newShortcuts);
	}

	%end

%end

// ------------------------------ SHOW APP BUNDLE ID IN SHORTCUTS ------------------------------

%group addGetBundleIDShortcutGroup

	%hook SBIconView

	- (NSArray*)applicationShortcutItems
	{
		NSArray *originalArray = %orig;

		NSMutableArray *shortcutsArray = [originalArray mutableCopy];
		if(!shortcutsArray)
			shortcutsArray = [NSMutableArray new];

		NSString *applicationBundleIdentifier;
		if([self respondsToSelector: @selector(applicationBundleIdentifier)]) 
			applicationBundleIdentifier = [self applicationBundleIdentifier];
		else if([self respondsToSelector: @selector(applicationBundleIdentifierForShortcuts)])
			applicationBundleIdentifier = [self applicationBundleIdentifierForShortcuts];
		
		if(applicationBundleIdentifier)
		{
			SBSApplicationShortcutItem *item = [[%c(SBSApplicationShortcutItem) alloc] init];
			[item setLocalizedTitle: applicationBundleIdentifier];
			[item setLocalizedSubtitle: @"Click To Copy"];
			[item setBundleIdentifierToLaunch: nil];
			[item setType: @"com.johnzaro.perfecthomescreen13.application-shortcut-item.app-bundleid"];
			[shortcutsArray addObject: item];
		}

		return [shortcutsArray copy];
	}

	%end

	%hook SBIconController

	- (BOOL)iconManager: (id)arg1 shouldActivateApplicationShortcutItem: (id)arg2 atIndex: (unsigned long long)arg3 forIconView: (id)arg4
	{
		NSString *shortcutType = [(SBSApplicationShortcutItem*)arg2 type];
		if([shortcutType isEqualToString: @"com.johnzaro.perfecthomescreen13.application-shortcut-item.app-bundleid"])
		{
			[[UIPasteboard generalPasteboard] setString: [arg2 localizedTitle]];
			return NO;
		}
		else return %orig;
	}

	%end

%end

// ------------------------------ ENABLE / DISABLE HOME SCREEN ROTATION ------------------------------

%group homeScreenRotationGroup

	%hook SpringBoard

	- (BOOL)_statusBarOrientationFollowsWindow:(id)arg1
	{
		return NO;
	}
	
	- (long long)homeScreenRotationStyle
	{
		if(enableHomeScreenRotation) return 2;
		else return 0;
	}

	%end

%end

// ------------------------------ CUSTOM HOME SCREEN LAYOUT ------------------------------

%group customHomeScreenLayoutGroup

	%hook _SBIconGridWrapperView

	- (void)setBounds: (CGRect)arg1
	{
		int rowsOffset = 0, columnsOffset = 0;
		if(customFolderRowsEnabled)
		{
			if(customFolderRows == 4) rowsOffset = 5;
			else if(customFolderRows == 5) rowsOffset = 13;
		}
		if(customFolderColumnsEnabled)
		{
			if(customFolderColumns == 4) columnsOffset = 5;
			else if(customFolderColumns == 5) columnsOffset = 13;
		}

		if(rowsOffset != 0 || columnsOffset != 0)
		{
			CGRect newFrame = CGRectMake(arg1.origin.x + columnsOffset, arg1.origin.y + rowsOffset, arg1.size.width - 2 * columnsOffset, arg1.size.height - 2 * rowsOffset);
			%orig(newFrame);
		}
		else %orig;
	}

	%end

// Idea For The "findLocation" Method @KritantaDev: https://github.com/KritantaDev/HomePlus

	%hook SBIconListGridLayoutConfiguration

	%property (nonatomic, assign) NSString *location;

	%new
	- (NSString*)findLocation
	{
		if([self location])
			return [self location];
		else
		{
			NSUInteger rows = MSHookIvar<NSUInteger>(self, "_numberOfPortraitRows");
			NSUInteger columns = MSHookIvar<NSUInteger>(self, "_numberOfPortraitColumns");
			
			if(rows == 1)
				[self setLocation: @"Dock"];
			else if(rows == 3 && columns == 3 || rows == 4 && columns == 4)
				[self setLocation: @"Folder"];
			else
				[self setLocation: @"Home"];
		}
		return [self location];
	}

	- (NSUInteger)numberOfPortraitRows
	{
		[self findLocation];
		
		if([[self location] isEqualToString: @"Dock"])
			return 1;
		else if([[self location] isEqualToString: @"Folder"] && customFolderRowsEnabled)
			return customFolderRows;
		else if([[self location] isEqualToString: @"Home"] && customHomeScreenRowsEnabled)
			return customHomeScreenRows;

		return %orig;
	}

	- (NSUInteger)numberOfLandscapeRows
	{
		[self findLocation];
		
		if([[self location] isEqualToString: @"Dock"] && customDockColumnsEnabled && !IS_iPAD)
			return customDockColumns;
		else if([[self location] isEqualToString: @"Folder"] && customFolderRowsEnabled)
			return customFolderRows;
		else if([[self location] isEqualToString: @"Home"])
		{
			if(IS_iPAD)
			{
				if(customHomeScreenRowsEnabled)
					return customHomeScreenRows;
			}
			else
			{
				if(customHomeScreenColumnsEnabled)
					return customHomeScreenColumns;
			}
		}
		
		return %orig;
	}

	- (NSUInteger)numberOfPortraitColumns
	{
		[self findLocation];
		
		if([[self location] isEqualToString: @"Dock"] && customDockColumnsEnabled && !IS_iPAD)
			return customDockColumns;
		else if([[self location] isEqualToString: @"Folder"] && customFolderColumnsEnabled)
			return customFolderColumns;
		else if([[self location] isEqualToString: @"Home"] && customHomeScreenColumnsEnabled)
			return customHomeScreenColumns;
		
		return %orig;
	}

	- (NSUInteger)numberOfLandscapeColumns
	{
		[self findLocation];
		
		if([[self location] isEqualToString: @"Dock"] && customDockColumnsEnabled && !IS_iPAD)
			return 1;
		else if([[self location] isEqualToString: @"Folder"] && customFolderColumnsEnabled)
			return customFolderColumns;
		else if([[self location] isEqualToString: @"Home"])
		{
			if(IS_iPAD)
			{
				if(customHomeScreenColumnsEnabled)
					return customHomeScreenColumns;
			}
			else
			{
				if(customHomeScreenRowsEnabled)
					return customHomeScreenRows;
			}
		}
		
		return %orig;
	}

	- (UIEdgeInsets)portraitLayoutInsets
	{
		UIEdgeInsets x = %orig;
		
		if(IS_iPAD)
			return x;

		[self findLocation];
		NSUInteger rows = [self numberOfLandscapeRows];
		NSUInteger columns = [self numberOfLandscapeColumns];
		
		if([[self location] isEqualToString: @"Folder"] && (customFolderRowsEnabled || customFolderColumnsEnabled))
		{
			int rowsOffset = 0, columnsOffset = 0;
			
			if(rows == 2)
				rowsOffset = 40;
			else if(rows > 3)
				rowsOffset = -15;
			
			if(columns == 2)
				columnsOffset = 40;
			else if(columns > 3)
				columnsOffset = -15;
			
			if(rowsOffset != 0 || columnsOffset != 0)
				return UIEdgeInsetsMake(x.top + rowsOffset, x.left + columnsOffset, x.bottom + rowsOffset, x.right + columnsOffset);
		}
		else if([[self location] isEqualToString: @"Home"] && (customHomeScreenRowsEnabled || customHomeScreenColumnsEnabled))
		{
			int rowsOffset = 0, columnsOffset = 0;
			
			if(rows == 3)
				rowsOffset = 100;
			else if(rows == 4)
				rowsOffset = 60;
			else if(rows > 6)
				rowsOffset = -20;

			if(columns == 3)
				columnsOffset = 30;
			else if(columns > 4)
				columnsOffset = -15;
			
			if(rowsOffset != 0 || columnsOffset != 0)
				return UIEdgeInsetsMake(x.top + rowsOffset, x.left + columnsOffset, x.bottom + rowsOffset, x.right + columnsOffset);
		}
		return x;
	}

	- (UIEdgeInsets)landscapeLayoutInsets
	{
		UIEdgeInsets x = %orig;
		
		if(IS_iPAD)
			return x;

		[self findLocation];
		NSUInteger rows = [self numberOfLandscapeRows];
		NSUInteger columns = [self numberOfLandscapeColumns];
		
		if([[self location] isEqualToString: @"Folder"] && (customFolderRowsEnabled || customFolderColumnsEnabled))
		{
			int rowsOffset = 0, columnsOffset = 0;
			
			if(rows == 2)
				rowsOffset = 40;
			else if(rows > 3)
				rowsOffset = -15;

			if(columns == 2)
				columnsOffset = 40;
			else if(columns > 3)
				columnsOffset = -15;
			
			if(rowsOffset != 0 || columnsOffset != 0)
				return UIEdgeInsetsMake(x.top + rowsOffset, x.left + columnsOffset, x.bottom + rowsOffset, x.right + columnsOffset);
		}
		else if([[self location] isEqualToString: @"Home"] && (customHomeScreenRowsEnabled || customHomeScreenColumnsEnabled))
		{
			int rowsOffset = 0, columnsOffset = 0;
			
			if(rows == 3)
				columnsOffset = 100;
			else if(rows == 4 || rows == 5 || rows == 6)
				columnsOffset = 70;
			else if(rows > 6)
				columnsOffset = 60;
			
			if(columns == 3)
				rowsOffset = -20;
			else if(columns == 4)
				rowsOffset = -40;
			else if(columns >= 5)
				rowsOffset = -60;
			
			if(rowsOffset != 0 || columnsOffset != 0)
				return UIEdgeInsetsMake(x.top + rowsOffset, x.left + columnsOffset + 20, x.bottom + rowsOffset + 20, x.right + columnsOffset - 20);
		}
		return x;
	}

	%end

	%hook SBIconListView 

	- (NSUInteger)maximumIconCount
	{
		return customHomeScreenRows * customHomeScreenColumns;
	}

	%end

%end

%group customBgTextColorGroup

	%hook SBMutableIconLabelImageParameters

	- (void)setFocusHighlightColor: (id)arg
	{
		%orig(customBgTextColor);
	}

	%end

%end

%group customTextColorGroup

	%hook SBMutableIconLabelImageParameters

	- (void)setTextColor: (id)arg
	{
		%orig(customTextColor);
	}

	%end

%end

%group customDockRadiusGroup

	%hook SBDockView

	- (void)layoutSubviews
	{
		%orig;
		UIView *backgroundView = [self subviews][0];
		[[backgroundView layer] setCornerRadius: dockCornerRadius];
	}

	%end

%end

%group hidePageDotsGroup

	%hook SBIconListPageControl

	- (void)layoutSubviews
	{
		[self setHidden: YES];
	}

	%end

%end

%group disableParallaxEffectGroup

	%hook UIView

	+ (void)_setShouldEnableUIKitParallaxEffects: (BOOL)arg1
	{
		%orig(NO);
	}

	%end

	%hook SBFWallpaperOptions

	- (BOOL)parallaxEnabled
	{
		return NO;
	}

	%end

	%hook SBFWallpaperView

	+ (BOOL)_allowsParallax
	{
		return NO;
	}

	+ (BOOL)_shouldScaleForParallax
	{
		return NO;
	}

	- (BOOL)parallaxEnabled
	{
		return NO;
	}

	%end

	%hook SBFStaticWallpaperView

	+ (BOOL)_allowsParallax
	{
		return NO;
	}

	%end

	%hook SBFScrollableStaticWallpaperView

	+ (BOOL)_shouldScaleForParallax
	{
		return NO;
	}

	%end

	%hook SBSUIWallpaperPreviewViewController

	- (BOOL)motionEnabled
	{
		return NO;
	}

	%end

	%hook SBFParallaxSettings

	- (BOOL)slideEnabled
	{
		return NO;
	}

	- (BOOL)tiltEnabled
	{
		return NO;
	}

	- (BOOL)increaseEnabled
	{
		return NO;
	}

	%end

	%hook _UIMotionEffectEngine

	- (BOOL)_isSuspended
	{
		return YES;
	}

	+ (BOOL)_motionEffectsSupported
	{
		return NO;
	}

	+ (BOOL)_motionEffectsEnabled
	{
		return NO;
	}

	%end

	%hook _UIMotionAnalyzer

	- (id)initWithSettings: (id)arg1
	{
		return nil;
	}

	%end

%end

%ctor
{
	@autoreleasepool
	{
		pref = [[HBPreferences alloc] initWithIdentifier: @"com.johnzaro.perfecthomescreen13prefs"];
		[pref registerDefaults:
		@{
			@"enabled": @NO,
			@"disableParallaxEffect": @NO,
			@"hideAppLabels": @NO,
			@"hideBlueDot": @NO,
			@"customBgTextColorEnable": @NO,
			@"customTextColorEnable": @NO,
			@"progressBarWhenDownloading": @NO,
			@"enableCustomProgressBarColor": @NO,
			@"hideAppIcons": @NO,
			@"enableCustomDockRadius": @NO,
			@"dockCornerRadius": @30,
			@"hideFolderTitle": @NO,
			@"folderTitleBold": @NO,
			@"enableFolderTitleCustomFontSize": @NO,
			@"enableCustomFolderTitleColor": @NO,
			@"autoCloseFolders": @NO,
			@"pinchToCloseFolder": @NO,
			@"enableCustomFolderIconBackgroundColor": @NO,
			@"enableCustomFolderCornerRadius": @NO,
			@"folderCornerRadius": @38,
			@"enableCustomFolderBackgroundColor": @NO,
			@"customCornerRadius": @NO,
			@"iconCornerRadius": @20,
			@"hideWidgetsIn3DTouch": @NO,
			@"hideShareAppShortcut": @NO,
			@"addGetBundleIDShortcut": @NO,
			@"enableHomeScreenRotation": @NO,
			@"customHomeScreenLayoutEnabled": @NO,
			@"customHomeScreenRowsEnabled": @NO,
			@"customHomeScreenColumnsEnabled": @NO,
			@"customFolderRowsEnabled": @NO,
			@"customFolderColumnsEnabled": @NO,
			@"customDockColumnsEnabled": @NO,
			@"customHomeScreenRows": @6,
			@"customHomeScreenColumns": @4,
			@"customFolderRows": @3,
			@"customFolderColumns": @3,
			@"customDockColumns": @4
    	}];

		enabled = [pref boolForKey: @"enabled"];
		if(enabled)
		{
			disableParallaxEffect = [pref boolForKey: @"disableParallaxEffect"];
			hideAppLabels = [pref boolForKey: @"hideAppLabels"];
			hideBlueDot = [pref boolForKey: @"hideBlueDot"];
			customBgTextColorEnable = [pref boolForKey: @"customBgTextColorEnable"];
			customTextColorEnable = [pref boolForKey: @"customTextColorEnable"];
			progressBarWhenDownloading = [pref boolForKey: @"progressBarWhenDownloading"];
			enableCustomProgressBarColor = [pref boolForKey: @"enableCustomProgressBarColor"];

			hideAppIcons = [pref boolForKey: @"hideAppIcons"];
			enableCustomDockRadius = [pref boolForKey: @"enableCustomDockRadius"];
			hideFolderTitle = [pref boolForKey: @"hideFolderTitle"];
			folderTitleBold = [pref boolForKey: @"folderTitleBold"];
			enableFolderTitleCustomFontSize = [pref boolForKey: @"enableFolderTitleCustomFontSize"];
			enableCustomFolderTitleColor = [pref boolForKey: @"enableCustomFolderTitleColor"];
			autoCloseFolders = [pref boolForKey: @"autoCloseFolders"];
			pinchToCloseFolder = [pref boolForKey: @"pinchToCloseFolder"];
			enableCustomFolderIconBackgroundColor = [pref boolForKey: @"enableCustomFolderIconBackgroundColor"];
			enableCustomFolderCornerRadius = [pref boolForKey: @"enableCustomFolderCornerRadius"];
			enableCustomFolderBackgroundColor = [pref boolForKey: @"enableCustomFolderBackgroundColor"];
			customCornerRadius = [pref boolForKey: @"customCornerRadius"];
			hideWidgetsIn3DTouch = [pref boolForKey: @"hideWidgetsIn3DTouch"];
			hideShareAppShortcut = [pref boolForKey: @"hideShareAppShortcut"];
			addGetBundleIDShortcut = [pref boolForKey: @"addGetBundleIDShortcut"];
			enableHomeScreenRotation = [pref boolForKey: @"enableHomeScreenRotation"];
			hidePageDots = [pref boolForKey: @"hidePageDots"];

			NSDictionary *preferencesDictionary = [NSDictionary dictionaryWithContentsOfFile: @"/var/mobile/Library/Preferences/com.johnzaro.perfecthomescreen13prefs.colors.plist"];
			
			if(customBgTextColorEnable || customTextColorEnable || progressBarWhenDownloading) 
			{
				customBgTextColor = [SparkColourPickerUtils colourWithString: [preferencesDictionary objectForKey: @"customBgTextColor"] withFallback: @"#FFFFFF"];
				customTextColor = [SparkColourPickerUtils colourWithString: [preferencesDictionary objectForKey: @"customTextColor"] withFallback: @"#FF9400"];
				
				if(enableCustomProgressBarColor) 
					customProgressBarColor = [SparkColourPickerUtils colourWithString: [preferencesDictionary objectForKey: @"customProgressBarColor"] withFallback: @"#FF9400"];
			}

			if(disableParallaxEffect)
				%init(disableParallaxEffectGroup);
			if(hideAppLabels)
				%init(hideAppLabelsGroup);
			if(hideBlueDot)
				%init(hideBlueDotGroup);
			if(customBgTextColorEnable)
				%init(customBgTextColorGroup);
			if(customTextColorEnable)
				%init(customTextColorGroup);
			if(hideAppIcons)
				%init(hideAppIconsGroup);
			if(enableCustomDockRadius)
			{
				dockCornerRadius = [pref integerForKey: @"dockCornerRadius"];
				%init(customDockRadiusGroup);
			} 
			if(hideFolderTitle)
				%init(hideFolderTitleGroup);
			if(folderTitleBold)
				%init(folderTitleBoldGroup);
			if(enableFolderTitleCustomFontSize) 
			{
				folderTitleCustomFontSize = [pref integerForKey: @"folderTitleCustomFontSize"];
				%init(folderTitleCustomFontSizeGroup);
			}
			if(enableCustomFolderTitleColor) 
			{
				customFolderTitleColor = [SparkColourPickerUtils colourWithString: [preferencesDictionary objectForKey: @"customFolderTitleColor"] withFallback: @"#FF9400"];
				%init(customFolderTitleColorGroup);
			}
			if(autoCloseFolders)
				%init(autoCloseFoldersGroup);
			if(pinchToCloseFolder)
				%init(pinchToCloseFolderGroup);
			if(enableCustomFolderIconBackgroundColor)
			{
				customFolderIconBackgroundColor = [SparkColourPickerUtils colourWithString: [preferencesDictionary objectForKey: @"customFolderIconBackgroundColor"] withFallback: @"#FF9400:1.0"];
				%init(customFolderIconBackgroundColorGroup);
			}
			if(enableCustomFolderCornerRadius) 
			{
				folderCornerRadius = [pref integerForKey: @"folderCornerRadius"];
				%init(customFolderCornerRadiusGroup);
			}
			if(enableCustomFolderBackgroundColor)
			{
				customFolderBackgroundColor = [SparkColourPickerUtils colourWithString: [preferencesDictionary objectForKey: @"customFolderBackgroundColor"] withFallback: @"#FF9400:1.0"];
				%init(customFolderBackgroundColorGroup);
			}
			// if(customCornerRadius)
			// {
			// 	iconCornerRadius = [pref integerForKey: @"iconCornerRadius"];
			// 	%init(customCornerRadiusGroup);
			// } 
			if(hideWidgetsIn3DTouch)
				%init(hideWidgetsIn3DTouchGroup);
			if(hideShareAppShortcut)
				%init(hideShareAppShortcutGroup);
			if(addGetBundleIDShortcut)
				%init(addGetBundleIDShortcutGroup);
			if(progressBarWhenDownloading)
				%init(progressBarWhenDownloadingGroup);
			if(hidePageDots)
				%init(hidePageDotsGroup);

			if(!IS_iPAD)
				%init(homeScreenRotationGroup);

			customHomeScreenLayoutEnabled = [pref boolForKey: @"customHomeScreenLayoutEnabled"];
			if(customHomeScreenLayoutEnabled)
			{
				customHomeScreenRowsEnabled = [pref boolForKey: @"customHomeScreenRowsEnabled"];
				customHomeScreenColumnsEnabled = [pref boolForKey: @"customHomeScreenColumnsEnabled"];
				customFolderRowsEnabled = [pref boolForKey: @"customFolderRowsEnabled"];
				customFolderColumnsEnabled = [pref boolForKey: @"customFolderColumnsEnabled"];
				customDockColumnsEnabled = [pref boolForKey: @"customDockColumnsEnabled"];

				customHomeScreenRows = [pref unsignedIntegerForKey: @"customHomeScreenRows"];
				customHomeScreenColumns = [pref unsignedIntegerForKey: @"customHomeScreenColumns"];
				customFolderRows = [pref unsignedIntegerForKey: @"customFolderRows"];
				customFolderColumns = [pref unsignedIntegerForKey: @"customFolderColumns"];
				customDockColumns = [pref unsignedIntegerForKey: @"customDockColumns"];

				%init(customHomeScreenLayoutGroup);
			}
		}
	}
}
