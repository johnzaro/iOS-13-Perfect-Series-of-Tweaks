@interface UIView ()
- (CGPoint)origin;
@end

@interface CKMessagesController: UIViewController
- (void)showConversationList: (BOOL)arg;
@end

@interface IMChat: NSObject
- (void)_targetToService: (id)arg1 newComposition: (BOOL)arg2;
@end

@interface CKConversation: NSObject
- (IMChat*)chat;
- (NSString*)serviceDisplayName;
@end

@interface CKMessageEntryView: UIView
@property(nonatomic, retain) CKConversation *conversation;
@property(nonatomic, retain) UIButton *sendButton;
- (CKConversation*)conversation;
- (void)showPulse;
@end

@interface IMServiceImpl: NSObject
+ (id)serviceWithName: (NSString*)arg1;
@end

@interface PulsingHaloLayer: CAReplicatorLayer
@property(nonatomic, strong) CALayer *effect;
@property(nonatomic, strong) CAAnimationGroup *animationGroup;
- (id)init;
@end