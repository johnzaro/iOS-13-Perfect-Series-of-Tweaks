@interface UILabel ()
- (void)mt_removeAllVisualStyling;
@end

@interface MTVisualStylingProvider : NSObject
- (void)stopAutomaticallyUpdatingView:(id)arg1;
@end

@interface PLPlatterHeaderContentView: UIView
- (void)_updateTextAttributesForDateLabel;
@property(getter=_titleLabel, nonatomic, readonly) UILabel *titleLabel;
@property(getter=_dateLabel, nonatomic, readonly) UILabel *dateLabel;
@property(nonatomic, retain) UIColor *dateColor;
@end

@interface PLPlatterView : UIView
@end

@interface PLTitledPlatterView : PLPlatterView
@end

@interface BSUIEmojiLabelView: UIView
@property(nonatomic, readonly) UILabel *contentLabel;
@end

@interface NCNotificationContentView: UIView
@property(setter=_setPrimaryLabel:, getter=_primaryLabel, nonatomic, retain) UILabel *primaryLabel;                         //@synthesize primaryLabel=_primaryLabel - In the implementation block
@property(setter=_setPrimarySubtitleLabel:, getter=_primarySubtitleLabel, nonatomic, retain) UILabel *primarySubtitleLabel; //@synthesize primarySubtitleLabel=_primarySubtitleLabel - In the implementation block
@property(getter=_secondaryLabel, nonatomic, readonly) UILabel *secondaryLabel;
@property(setter=_setSummaryLabel:, getter=_summaryLabel, nonatomic, retain) BSUIEmojiLabelView *summaryLabel;
@end

@interface BSUIRelativeDateLabel
@property(assign, nonatomic) NSString *text;
- (void)sizeToFit;
@end

@interface NCNotificationListStalenessEventTracker : NSObject
@end

@interface NCNotificationStructuredSectionList : NSObject
- (void)clearAllNotificationRequests;
@end

@interface NCNotificationMasterList : NSObject
@property (nonatomic,retain) NCNotificationListStalenessEventTracker * notificationListStalenessEventTracker;
-(void)setNotificationListStalenessEventTracker:(NCNotificationListStalenessEventTracker *)arg1;
-(NCNotificationListStalenessEventTracker *)notificationListStalenessEventTracker;
-(BOOL)_isNotificationRequestForIncomingSection:(id)arg1;
-(BOOL)_isNotificationRequestForHistorySection:(id)arg1;
-(void)_migrateNotificationsFromList:(id)arg1 toList:(id)arg2 passingTest:(/*^block*/id)arg3 hideToList:(BOOL)arg4 clearRequests:(BOOL)arg5;
-(void)migrateNotifications;
- (NCNotificationStructuredSectionList *)incomingSectionList;
@end

@interface NCNotificationStructuredListViewController : UIViewController
- (NCNotificationMasterList *)masterList;
@end

@interface NCNotificationShortLookView: PLTitledPlatterView
@property(nonatomic, copy) NSArray *iconButtons;
@end

@interface NCNotificationLongLookView : UIView
@property(nonatomic, copy) NSArray *iconButtons;
@property(nonatomic, copy) UIView *customContentView;
@end

@interface NCNotificationViewController : UIViewController
@end

@interface MTMaterialView : UIView
@property(nonatomic, retain) NSString *groupNameBase;
@end

@interface NCNotificationListCellActionButton : UIControl
@property(nonatomic, retain) MTMaterialView *backgroundView;
@property(nonatomic, retain) UILabel *titleLabel;
@end

@interface NCNotificationListCellActionButtonsView : UIView
@property(nonatomic, retain) UIStackView *buttonsStackView;
@end

@interface NCNotificationViewControllerView : UIView
@property(assign, nonatomic) PLPlatterView *contentView;
@end

@interface NCNotificationShortLookViewController : UIViewController
@end

@interface NCNotificationListCell : UICollectionViewCell
@property(nonatomic, retain) NCNotificationViewController *contentViewController;
@property(nonatomic, retain) NCNotificationListCellActionButtonsView *leftActionButtonsView;
@end

@interface NCNotificationListSectionRevealHintView: UIView
@property (nonatomic, assign, readwrite, getter = isHidden) BOOL hidden;
@end
