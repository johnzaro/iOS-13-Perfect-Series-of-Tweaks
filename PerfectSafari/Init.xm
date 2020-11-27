#import "SafariPreferences.h"

#define IS_PAD ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

extern void initPerfectSafari();
extern void initSafariPlusFeatures();

%ctor
{
    @autoreleasepool
	{
        if([[SafariPreferences sharedInstance] enabled])
        {
            initSafariPlusFeatures();
            initPerfectSafari();
        }
    }
}