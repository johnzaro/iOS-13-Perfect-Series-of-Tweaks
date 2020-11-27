@interface BBServer: NSObject
- (void)publishBulletin:(id)arg1 destinations:(unsigned long long)arg2;
@end

@interface BBAction: NSObject
+ (id)actionWithLaunchBundleID:(id)arg1 callblock:(id)arg2;
@end

@interface BBBulletin: NSObject
@property(copy, nonatomic) NSString *title;
@property(copy, nonatomic) NSString *message;
@property(copy, nonatomic) NSString *sectionID;
@property(copy, nonatomic) NSString *bulletinID;
@property(retain, nonatomic) NSString *recordID;
@property(copy, nonatomic) NSString *publisherBulletinID;
@property(retain, nonatomic) NSDate *date;
@property(assign, nonatomic) BOOL turnsOnDisplay;
@property(copy, nonatomic) id defaultAction;
@end

@interface SBApplication: NSObject
- (NSString *)bundleIdentifier;
@end

@interface SBMediaController: NSObject
- (SBApplication*)nowPlayingApplication;
- (BOOL)isPlaying;
@end

@interface SBCoverSheetPresentationManager: NSObject
+ (id)sharedInstance;
- (BOOL)isPresented;
@end