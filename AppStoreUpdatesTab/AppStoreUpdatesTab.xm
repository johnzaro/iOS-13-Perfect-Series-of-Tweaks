@interface UITabBarItem ()
- (void)setAction: (SEL)arg1;
- (id)view;
@end

%hook UITabBar

- (NSArray*)items
{
	NSArray *array = %orig;
	for(UITabBarItem *item in array)
	{
		if([[item title] isEqualToString: @"Arcade"])
		{
			[item setTitle: @"Updates"];
			[item setImage: [UIImage imageWithContentsOfFile: @"/var/mobile/Library/com.johnzaro.AppStoreUpdatesTab.bundle/UpdatesTabIcon-38-56-.png"]];
			[item setAction: nil];
			[[item view] addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(openUpdates)]];
			break;
		}
	}
	return array;
}

%new
- (void)openUpdates
{
	[[%c(UIApplication) sharedApplication] openURL: [NSURL URLWithString: @"itms-apps://apps.apple.com/updates"]];
}

%end
