@interface UIDateLabel: UILabel
@property(nonatomic, strong) NSDate *date;
@end

@interface MPRecentsTableViewCell: UITableViewCell
@property(nonatomic, strong) UIDateLabel *callerDateLabel;
@end

@interface PHBottomBarButton: UIView
@property(nonatomic, copy) UIView *overlayView;
- (void)layoutSubviews;
@end

@interface PHHandsetDialerDeleteButton: UIView
- (void)layoutSubviews;
@end

@interface CHRecentCall: NSObject
@property unsigned int callStatus;
@end

@interface PHRecentsCell: UITableViewCell
{
    UILabel *_callerNameLabel;
    CHRecentCall *_call;
}
@end

@interface PHRecentsViewController: UIViewController
- (void)tableView: (UITableView*)arg1 willDisplayCell: (PHRecentsCell*)arg2 forRowAtIndexPath: (NSIndexPath*)arg3;
@end

@interface MPRecentsTableViewController
- (CHRecentCall*)recentCallAtTableViewIndex: (NSInteger)index;
@end

@interface NUIContainerStackView
- (NSArray<UILabel*>*)arrangedSubviews;
@end

@interface MPRecentsTableViewCell (iOS13)
@property (nonatomic,retain) NUIContainerStackView *titleStackView; 
@end
