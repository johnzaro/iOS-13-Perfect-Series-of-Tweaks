@interface PSSpecifier: NSObject
@property(nonatomic, retain) NSString *identifier;
@end

@interface PSTableCell: UITableViewCell
@property(nonatomic, retain) PSSpecifier *specifier;
- (void)setValue: (id)arg1;
- (void)setForceHideDisclosureIndicator: (BOOL)arg;
@end

@interface _UITableViewCellSeparatorView: UIView
@end

@interface BatteryHealthUIController : UIViewController
@property(readwrite, assign) int maximumCapacityPercent;
- (void)updateData;
- (void)updateMaximumCapacity;
@end

@interface UIView ()
- (UIViewController*)_viewControllerForAncestor;
@end

@interface _UINavigationBarContentView: UIView
- (NSObject*)backButtonItem;
@end

@interface CoreTelephonyClient: NSObject
{
    id _delegate;
    id _userQueue;
    id _mux;
}
@property(assign, nonatomic) id userQueue;
@property(nonatomic, retain) id mux;
@property(assign, nonatomic) id delegate;
+ (instancetype)sharedMultiplexer;
- (id)proxyWithErrorHandler:(/*^block*/ id)arg1;
- (void)dataUsageForLastPeriods: (unsigned long long)arg1 completion: (/*^block*/ id)arg2;
@end

@interface CTDataUsage: NSObject
@property(assign, nonatomic) unsigned long long cellularHome;
@property(assign, nonatomic) unsigned long long cellularRoaming;
@property(assign, nonatomic) unsigned long long wifi;
@end

@interface CTDeviceDataUsage: NSObject
- (CTDataUsage*)totalDataUsageForPeriod: (unsigned long long)arg1;
- (id)totalDataUsedForPeriod: (unsigned long long)arg1;
@end

@interface PSUICoreTelephonyDataCache: NSObject
+ (instancetype)sharedInstance;
@property(nonatomic, retain) CoreTelephonyClient *client;
@end

@interface STStorageDiskMonitor: NSObject
+ (id)sharedMonitor;
- (void)updateDiskSpace;
- (long long)storageSpace;
- (long long)deviceSize;
- (long long)lastFree;
@end