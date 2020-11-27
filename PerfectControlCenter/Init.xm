#import "ControlCenterPreferences.h"

extern void initPerfectControlCenter();
extern void initCCModulesCustomSize();

%ctor
{
	@autoreleasepool
	{
		ControlCenterPreferences *preferences = [ControlCenterPreferences sharedInstance];
		if([preferences enabled])
		{
			initPerfectControlCenter();

			if([preferences customConnectivitySizeEnabled] || [preferences customMusicSizeEnabled])
				initCCModulesCustomSize();
		}
	}
}