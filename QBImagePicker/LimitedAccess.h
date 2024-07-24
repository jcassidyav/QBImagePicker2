// LimitedAccess.h

#import <UIKit/UIKit.h>



@interface LimitedAccess : NSObject

- (instancetype)initWithParentViewController:(UIViewController *)parentViewController prompt:(NSString *)prompt;
- (UIView *)createLimitedAccessViewWithWidth:(CGFloat)width;
- (void)showMenu;

@property (nonatomic, assign) BOOL isLimitedAccess;
@property (nonatomic, strong) NSMutableAttributedString *limitedPrompt;

@end


