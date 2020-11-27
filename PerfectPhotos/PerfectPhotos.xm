#import "PerfectPhotos.h"
#import <Cephei/HBPreferences.h>

static HBPreferences *pref;
static BOOL enabled;
static BOOL allowSelectAll;
static BOOL unlimitedZoom;
static BOOL skipDeleteConfirm;
static BOOL photoInfo;
static BOOL completelyDeleteMedia;

// ------------------------- ALLOW SELECT ALL IN ALBUMS -------------------------

%group allowSelectAllGroup

	%hook PUPhotosAlbumViewController

	- (BOOL)allowSelectAllButton
	{
		return YES;
	}

	%end

%end

// ------------------------- ALLOW UNLIMITED ZOOM IN PHOTOS -------------------------

%group unlimitedZoomGroup

	%hook PUUserTransformView

	- (void)_setPreferredMaximumZoomScale: (double)arg
	{
		%orig(9999);
	}

	%end

%end

// ------------------------- SKIP DELETE CONFIRMATION -------------------------

%group skipDeleteConfirmGroup

	%hook PUDeletePhotosActionController

	- (BOOL)shouldSkipDeleteConfirmation
	{
		return YES;
	}

	%end

%end

// ------------------------- DETAILED PHOTO INFO IN NAVIGATION BAR -------------------------

// original tweak by @shepgoba: https://github.com/shepgoba/PhotoInfo

%group photoInfoGroup

	%hook PUPhotoBrowserTitleViewController

	- (void)_setTimeDescription: (id)arg1
	{
		PHAsset *asset = [(PUOneUpViewController*)[(PUNavigationController*)[[self view] performSelector: @selector(_viewControllerForAncestor)] _currentToolbarViewController] pu_debugCurrentAsset];
		if (asset)
		{
			CGSize imageSize = [asset imageSize];
			NSString *correctURL = [[[asset mainFileURL] absoluteString] stringByReplacingOccurrencesOfString: @"file://" withString: @""];
			NSDictionary *fileAttributes;
			NSNumber *fileSizeNumber;
			long long fileSize;
			float fileSizeMB;
			BOOL isDirectory;

			if([[NSFileManager defaultManager] fileExistsAtPath: correctURL isDirectory: &isDirectory])
			{
				fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath: correctURL error: nil];
				fileSizeNumber = [fileAttributes objectForKey: NSFileSize];
				fileSize = [fileSizeNumber longLongValue];
				fileSizeMB = (float)fileSize / (1024 * 1024);
			}
			else fileSizeMB = 0;

			NSString *newTitle = [NSString stringWithFormat: @"%@ (%ix%i, %.02fMB)", arg1, (int)imageSize.width, (int)imageSize.height, fileSizeMB];
			
			%orig(newTitle);
		}
		else %orig;
	}

	%end

%end

// ------------------------- DELETE MEDIA COMPLETELY -------------------------

%group completelyDeleteMediaGroup

	%hook PUDeletePhotosActionController

	- (id)initWithAction: (long long)arg1 assets: (id)arg2 delegate: (id)arg3
	{
		if(arg1 != 2)
			return %orig(4, arg2, arg3);
		else
			return %orig;
	}

	%end

%end

%ctor
{
	@autoreleasepool
	{
		pref = [[HBPreferences alloc] initWithIdentifier: @"com.johnzaro.perfectphotosprefs"];
		[pref registerBool: &enabled default: NO forKey: @"enabled"];
		if(enabled)
		{
			[pref registerBool: &allowSelectAll default: NO forKey: @"allowSelectAll"];
			[pref registerBool: &unlimitedZoom default: NO forKey: @"unlimitedZoom"];
			[pref registerBool: &skipDeleteConfirm default: NO forKey: @"skipDeleteConfirm"];
			[pref registerBool: &photoInfo default: NO forKey: @"photoInfo"];
			[pref registerBool: &completelyDeleteMedia default: NO forKey: @"completelyDeleteMedia"];

			if(allowSelectAll)
				%init(allowSelectAllGroup);
			if(unlimitedZoom)
				%init(unlimitedZoomGroup);
			if(skipDeleteConfirm)
				%init(skipDeleteConfirmGroup);
			if(photoInfo)
				%init(photoInfoGroup);
			if(completelyDeleteMedia)
				%init(completelyDeleteMediaGroup);
		}
	}
}