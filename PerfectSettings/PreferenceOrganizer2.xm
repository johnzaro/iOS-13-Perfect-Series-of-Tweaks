/*
Copyright (c) 2013-2019, Karen/あけみ, Eliz, Julian Weiss (insanj), ilendemli, Hiraku (hirakujira), Gary Lin (garynil).
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "PreferenceOrganizer2.h"
#import <Cephei/HBPreferences.h>

static NSMutableArray *AppleAppSpecifiers, *TweakSpecifiers, *AppStoreAppSpecifiers;

static BOOL ddiIsMounted = 0;
static BOOL deviceShowsTVProviders = 0;

static HBPreferences *pref;
static NSString *tweaksTitle;
static NSString *systemAppsTitle;
static NSString *appStoreAppsTitle;
static NSInteger organizedSettingsPosition;

@implementation AppleAppSpecifiersController

- (NSArray*)specifiers
{
	if(!_specifiers)
		self.specifiers = AppleAppSpecifiers;
	return _specifiers;
}

@end

@implementation TweakSpecifiersController

- (NSArray*)specifiers
{
	if(!_specifiers)
		self.specifiers = TweakSpecifiers;
	return _specifiers;
}

@end

@implementation AppStoreAppSpecifiersController

- (NSArray*)specifiers
{
	if(!_specifiers)
		self.specifiers = AppStoreAppSpecifiers;
	return _specifiers;
}

@end

%hook PSUIPrefsListController

- (void)_reallyLoadThirdPartySpecifiersForApps: (NSArray*)apps withCompletion: (void (^)(NSArray <PSSpecifier*> *thirdParty, NSDictionary *appleThirdParty))completion
{
	void (^newCompletion)(NSArray <PSSpecifier*> *, NSDictionary*) = ^(NSArray <PSSpecifier*> *thirdParty, NSDictionary *appleThirdParty) // thirdParty - self._thirdPartySpecifiers, appleThirdParty - self._movedThirdPartySpecifiers
	{
		if(completion)
			completion(thirdParty, appleThirdParty);
		
		NSMutableArray *specifiers = [[NSMutableArray alloc] initWithArray: [self specifiers]]; // Then add all third party specifiers into correct categories Also remove them from the original locations
		
		static dispatch_once_t onceToken;
		dispatch_once(&onceToken, 
		^{
			int groupID = 0;
			NSMutableDictionary *organizableSpecifiers = [[NSMutableDictionary alloc] init];
			NSString *currentOrganizableGroup = nil;
			
			// Loop that runs through all specifiers in the main Settings area. Once it cycles through all the specifiers for the pre-"Apple Apps" groups, starts filling the organizableSpecifiers array.
			// This currently compares identifiers to prevent issues with extra groups (such as the single "Developer" group). STORE . ... . DEVELOPER_SETTINGS . ...
			for(int i = 0; i < specifiers.count; i++) // We can't fast enumerate when order matters
			{
				PSSpecifier *s = (PSSpecifier*) specifiers[i];
				NSString *identifier = s.identifier ?: @"";
				
				if(s.cellType != 0) // If we're not a group cell...
				{
					if([identifier isEqualToString: @"DEVELOPER_SETTINGS"]) // If we're hitting the Developer settings area, regardless of position, we need to steal its group specifier from the previous group and leave it out of everything.
					{
						NSMutableArray *lastSavedGroup = organizableSpecifiers[currentOrganizableGroup];
						[lastSavedGroup removeObjectAtIndex: lastSavedGroup.count - 1];
						ddiIsMounted = 1; // If DEVELOPER_SETTINGS is present, then that means the DDI must have been mounted.
					}
					else if([identifier isEqualToString: @"STORE"]) // If we're in the first item of the iCloud/Mail/Notes... group, setup the key string, grab the group from the previously enumerated specifier, and get ready to shift things into it.
					{
						currentOrganizableGroup = identifier;
						
						NSMutableArray *newSavedGroup = [[NSMutableArray alloc] init];
						[newSavedGroup addObject: specifiers[i - 1]];
						[newSavedGroup addObject: s];

						[organizableSpecifiers setObject: newSavedGroup forKey: currentOrganizableGroup];
					}
					else if(currentOrganizableGroup)
						[organizableSpecifiers[currentOrganizableGroup] addObject: s];
				}
				else if(currentOrganizableGroup)// If we've already encountered groups before, but THIS specifier is a group specifier, then it COULDN'T have been any previously encountered group, but is still important to PreferenceOrganizer's organization. So, it must either be the Tweaks or Apps section.
				{
					if([identifier isEqualToString: @"VIDEO_SUBSCRIBER_GROUP"])
						deviceShowsTVProviders = 1;

					if(groupID < 2 + ddiIsMounted + deviceShowsTVProviders) // If the DDI is mounted, groupIDs will all shift down by 1, causing the categories to be sorted incorrectly. If an iOS 11 device is in a locale where the TV Provider option will show, groupID must be adjusted
					{
						groupID++;
						currentOrganizableGroup = @"STORE";
					}
					else if(groupID == 2 + ddiIsMounted + deviceShowsTVProviders)
					{
						groupID++;
						currentOrganizableGroup = @"TWEAKS";
					}
					else
					{
						groupID++;
						currentOrganizableGroup = @"APPS";
					}

					NSMutableArray *newSavedGroup = organizableSpecifiers[currentOrganizableGroup];
					if(!newSavedGroup)
						newSavedGroup = [[NSMutableArray alloc] init];

					[newSavedGroup addObject: s];
					[organizableSpecifiers setObject: newSavedGroup forKey: currentOrganizableGroup];
				}

				if(i == specifiers.count - 1 && groupID != 4 + ddiIsMounted)
				{
					groupID++;
					currentOrganizableGroup = @"APPS";
					NSMutableArray *newSavedGroup = organizableSpecifiers[currentOrganizableGroup];
					if(!newSavedGroup)
						newSavedGroup = [[NSMutableArray alloc] init];
					[organizableSpecifiers setObject: newSavedGroup forKey: currentOrganizableGroup];
				}
			}

			PSSpecifier *cydiaSpecifier;
			PSSpecifier *appleSpecifier;
			PSSpecifier *appstoreSpecifier;

			TweakSpecifiers = organizableSpecifiers[@"TWEAKS"];
			if([TweakSpecifiers count] != 0 && ((PSSpecifier*)TweakSpecifiers[0]).cellType == 0 && ((PSSpecifier*)TweakSpecifiers[1]).cellType == 0)
				[TweakSpecifiers removeObjectAtIndex: 0];
			if(TweakSpecifiers)
			{
				[specifiers removeObjectsInArray: TweakSpecifiers];
				cydiaSpecifier = [PSSpecifier preferenceSpecifierNamed: tweaksTitle target: self set: NULL get: NULL detail: [TweakSpecifiersController class] cell: [PSTableCell cellTypeFromString: @"PSLinkCell"] edit: nil];
				[cydiaSpecifier setProperty: [UIImage imageWithContentsOfFile: @"/Library/PreferenceBundles/PerfectSettingsPrefs.bundle/Tweaks.png"] forKey: @"iconImage"];
			}
			
			AppleAppSpecifiers = organizableSpecifiers[@"STORE"];
			if(AppleAppSpecifiers)
			{
				for(PSSpecifier* specifier in AppleAppSpecifiers) // Workaround for a bug in iOS 10 If all Apple groups (APPLE_ACCOUNT_GROUP, etc.) are deleted, it will crash
				{
					// We'll handle this later in insertMovedThirdPartySpecifiersAnimated
					if([specifier.identifier isEqualToString: @"MEDIA_GROUP"] || [specifier.identifier isEqualToString: @"ACCOUNTS_GROUP"] || [specifier.identifier isEqualToString: @"APPLE_ACCOUNT_GROUP"])
						continue;
					else
						[specifiers removeObject: specifier];
				}
				
				appleSpecifier = [PSSpecifier preferenceSpecifierNamed: systemAppsTitle target: self set: NULL get: NULL detail: [AppleAppSpecifiersController class] cell: [PSTableCell cellTypeFromString: @"PSLinkCell"] edit: nil];
				[appleSpecifier setProperty: [UIImage _applicationIconImageForBundleIdentifier: @"com.apple.Preferences" format: 0 scale: [UIScreen mainScreen].scale] forKey: @"iconImage"];

				[appleSpecifier setIdentifier: @"APPLE_APPS"]; // Setting this identifier for later use...

				NSMutableArray *specifiersToRemove = [[NSMutableArray alloc] init]; // Move deleted group specifiers to the end...
				for(int i = 0; i < specifiers.count; i++)
				{
					PSSpecifier *specifier = (PSSpecifier*) specifiers[i];
					
					if([specifier.identifier isEqualToString: @"MEDIA_GROUP"] || [specifier.identifier isEqualToString: @"ACCOUNTS_GROUP"] || [specifier.identifier isEqualToString: @"APPLE_ACCOUNT_GROUP"])
						[specifiersToRemove addObject: specifier];
				}
				[specifiers removeObjectsInArray: specifiersToRemove];
			}

			AppStoreAppSpecifiers = organizableSpecifiers[@"APPS"];
			if(AppStoreAppSpecifiers)
			{
				[specifiers removeObjectsInArray: AppStoreAppSpecifiers];
				appstoreSpecifier = [PSSpecifier preferenceSpecifierNamed: appStoreAppsTitle target: self set: NULL get: NULL detail: [AppStoreAppSpecifiersController class] cell: [PSTableCell cellTypeFromString: @"PSLinkCell"] edit: nil];
				[appstoreSpecifier setProperty: [UIImage _applicationIconImageForBundleIdentifier: @"com.apple.AppStore" format: 0 scale: [UIScreen mainScreen].scale] forKey: @"iconImage"];
			}

			if(organizedSettingsPosition == 0) // put categories on top of settings page
			{
				int currentIndex = 2;
				[specifiers insertObject: [PSSpecifier groupSpecifierWithName: nil] atIndex: currentIndex]; // add group to separate from the group below
				currentIndex++;
				if(TweakSpecifiers)
				{
					[specifiers insertObject: cydiaSpecifier atIndex: currentIndex];
					currentIndex++;
				}
				if(AppleAppSpecifiers)
				{
					[specifiers insertObject: appleSpecifier atIndex: currentIndex];
					currentIndex++;
				}
				if(AppStoreAppSpecifiers)
				{
					[specifiers insertObject: appstoreSpecifier atIndex: currentIndex];
					currentIndex++;
				}
			}
			else // put categories at the bottom of settings page
			{
				[specifiers addObject: [PSSpecifier groupSpecifierWithName: nil]];
				if(TweakSpecifiers)
					[specifiers addObject: cydiaSpecifier];
				if(AppleAppSpecifiers)
					[specifiers addObject: appleSpecifier];
				if(AppStoreAppSpecifiers)
					[specifiers addObject: appstoreSpecifier];
			}
		});

		[specifiers removeObjectsInArray: [MSHookIvar<NSMutableDictionary*>(self, "_movedThirdPartySpecifiers") allValues]]; // If we found Apple's third party apps, we really won't add them because this would mess up the UITableView row count check after the update

		NSMutableArray *itemsToDelete = [NSMutableArray array];
		for(PSSpecifier *specifier in AppleAppSpecifiers)
		{
			NSString *identifier = specifier.identifier;
			if([identifier isEqualToString: @"com.apple.news"] 
			|| [identifier isEqualToString: @"com.apple.iBooks"] 
			|| [identifier isEqualToString: @"com.apple.podcasts"] 
			|| [identifier isEqualToString: @"com.apple.itunesu"])
					[itemsToDelete addObject: specifier];
		}
		[AppleAppSpecifiers removeObjectsInArray: itemsToDelete];

		NSArray *appleThirdPartySpecifiers = [appleThirdParty allValues];
		[AppleAppSpecifiers addObjectsFromArray: appleThirdPartySpecifiers];
		[specifiers removeObjectsInArray: appleThirdPartySpecifiers];
		
		[AppStoreAppSpecifiers removeAllObjects];
		[AppStoreAppSpecifiers addObjectsFromArray: thirdParty];
		[specifiers removeObjectsInArray: thirdParty];

		[self setSpecifiers: specifiers];
	};
	%orig(apps, newCompletion);
}

%end

void initPreferenceOrganizer()
{
	pref = [[HBPreferences alloc] initWithIdentifier: @"com.johnzaro.perfectsettingsprefs"];
	tweaksTitle = [pref objectForKey: @"tweaksTitle"];
	systemAppsTitle = [pref objectForKey: @"systemAppsTitle"];
	appStoreAppsTitle = [pref objectForKey: @"appStoreAppsTitle"];
	organizedSettingsPosition = [pref integerForKey: @"organizedSettingsPosition"];

	%init;
}
