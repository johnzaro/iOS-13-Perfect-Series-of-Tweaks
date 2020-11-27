@interface TFNTwitterStatus: NSObject
@property(readonly, nonatomic) bool isPromoted;
@end

@interface TFNDataViewItem: NSObject
@property(retain, nonatomic) id _Nullable item;
@end

@interface TFNDataViewController
- (TFNDataViewItem *_Nullable)itemsInternalDataViewItemAtValidIndexPath:(id _Nullable)v1;
@end

@interface TFNItemsDataViewController: TFNDataViewController
- (id _Nullable)itemAtIndexPath:(id _Nullable)arg1;
@end
