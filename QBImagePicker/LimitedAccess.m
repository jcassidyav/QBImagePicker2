// LimitedAccess.m

#import "LimitedAccess.h"
@import PhotosUI;

@interface LimitedAccess ()

@property (nonatomic, weak) UIViewController *parentViewController;
@property (nonatomic, copy) NSString *suppliedPrompt;
@end

@implementation LimitedAccess

- (instancetype)initWithParentViewController:(UIViewController *)parentViewController prompt:(NSString *)prompt {
    self = [super init];
    if (self) {
        _parentViewController = parentViewController;
        if (@available(iOS 14, *)) {
            PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelReadWrite];
            _isLimitedAccess = status == PHAuthorizationStatusLimited;
            _suppliedPrompt = prompt;
            _limitedPrompt = [self createLimitedPrompt];
        } else {
            _isLimitedAccess = false;
        }
    }
    return self;
}

- (NSMutableAttributedString *)createLimitedPrompt {
    NSString *headerText;
    if(_suppliedPrompt == nil)
        headerText = @"You've given access to only a select number of photos. Manage";
    else
        headerText = _suppliedPrompt;
    
    NSMutableAttributedString *attributedHeaderText = [[NSMutableAttributedString alloc] initWithString:headerText];
    
    if(_suppliedPrompt == nil){
        // Find the range of the word "Manage" and set its color to blue
        NSRange blueTextRange = [headerText rangeOfString:@"Manage"];
        if (blueTextRange.location != NSNotFound) {
            [attributedHeaderText addAttribute:NSForegroundColorAttributeName value:[UIColor systemBlueColor] range:blueTextRange];
            
            // Get the range excluding the specified range
            NSRange firstPartRange = NSMakeRange(0, blueTextRange.location);
            NSRange secondPartRange = NSMakeRange(NSMaxRange(blueTextRange), attributedHeaderText.length - NSMaxRange(blueTextRange));
            
            [attributedHeaderText addAttribute:NSForegroundColorAttributeName value:[UIColor systemGrayColor] range:firstPartRange];
            [attributedHeaderText addAttribute:NSForegroundColorAttributeName value:[UIColor systemGrayColor] range:secondPartRange];
            
        }
    } else {
        [attributedHeaderText addAttribute:NSForegroundColorAttributeName value:[UIColor systemGrayColor]
                                     range:NSMakeRange(0, headerText.length) ];
    }
    
    // Set font size and color for the label
    UIFont *labelFont = [UIFont systemFontOfSize:13.0]; // Adjust the font size as needed
    [attributedHeaderText addAttribute:NSFontAttributeName value:labelFont range:NSMakeRange(0, headerText.length)];
    
    return attributedHeaderText;
}

- (UIView *)createLimitedAccessViewWithWidth:(CGFloat)width {
    if (@available(iOS 14, *)) {
        
        // Create an attributed string for the header label
        
        NSMutableAttributedString *attributedHeaderText = [self createLimitedPrompt];
                        
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        headerLabel.translatesAutoresizingMaskIntoConstraints = NO;
        headerLabel.attributedText = attributedHeaderText;
        headerLabel.numberOfLines = 0; // Allow text to wrap to multiple lines
        headerLabel.textAlignment = NSTextAlignmentCenter;
        
        
        // Calculate the required height for the label based on the attributed text
        CGSize labelSize = [headerLabel sizeThatFits:CGSizeMake(width - 32, CGFLOAT_MAX)];
        
        // Create the header view with a height based on the label size
        UIView *customHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, labelSize.height + 16)]; // Adjust additional space if needed
        customHeaderView.backgroundColor = [UIColor systemGray6Color];
        
        // Set the frame for the label within the calculated height
        headerLabel.frame = CGRectMake(16, 8, width - 32, labelSize.height);
        
        [customHeaderView addSubview:headerLabel];
        
        // Set constraints for the label to be centered and dynamically resize
        [NSLayoutConstraint activateConstraints:@[
            [headerLabel.topAnchor constraintEqualToAnchor:customHeaderView.topAnchor constant:8],
            [headerLabel.leadingAnchor constraintEqualToAnchor:customHeaderView.leadingAnchor constant:16],
            [headerLabel.trailingAnchor constraintEqualToAnchor:customHeaderView.trailingAnchor constant:-16],
            [headerLabel.bottomAnchor constraintEqualToAnchor:customHeaderView.bottomAnchor constant:-8],
        ]];
        
        // Add UITapGestureRecognizer to respond to the click
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showMenu)];
        [customHeaderView addGestureRecognizer:tapGesture];
        
        // Enable user interaction for the header view
        customHeaderView.userInteractionEnabled = YES;
        return customHeaderView;
    }
    // Set the customHeaderView as the tableHeaderView
    return nil;
}

- (void)showMenu {
    if (@available(iOS 14, *)) {
        UIAlertControllerStyle style = (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad)
            ? UIAlertControllerStyleAlert
            : UIAlertControllerStyleActionSheet;

        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Manage Access to Photos and Videos"
                                                                                 message:nil
                                                                          preferredStyle:style];
     
        // Option 1: Select More Photos
        UIAlertAction *selectMorePhotosAction = [UIAlertAction actionWithTitle:@"Select More Photos"
                                                                         style:UIAlertActionStyleDefault
                                                                       handler:^(UIAlertAction * _Nonnull action) {
            // Handle Select More Photos action
            NSLog(@"Select More Photos selected");
            
            [PHPhotoLibrary.sharedPhotoLibrary presentLimitedLibraryPickerFromViewController:self.parentViewController];
            
        }];
        [selectMorePhotosAction setValue:[self imageWithSystemName:@"checkmark.circle.fill"] forKey:@"image"]; // Add a system checkmark icon
        [alertController addAction:selectMorePhotosAction];
        
        // Option 2: Change Settings
        UIAlertAction *changeSettingsAction = [UIAlertAction actionWithTitle:@"Change Settings"
                                                                       style:UIAlertActionStyleDefault
                                                                     handler:^(UIAlertAction * _Nonnull action) {
            // Handle Change Settings action
            NSLog(@"Change Settings selected");
            NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            
            if ([[UIApplication sharedApplication] canOpenURL:settingsURL]) {
                [[UIApplication sharedApplication] openURL:settingsURL options:@{} completionHandler:nil];
            }
        }];
        [changeSettingsAction setValue:[self imageWithSystemName:@"gearshape.fill"] forKey:@"image"]; // Add a system settings icon
        [alertController addAction:changeSettingsAction];
        
        // Option 3: Cancel
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * _Nonnull action) {
            // Handle Cancel action
            NSLog(@"Cancel selected");
        }];
        [alertController addAction:cancelAction];
        
        // Present the alert controller
        [self.parentViewController presentViewController:alertController animated:YES completion:nil];
    }
}

- (UIImage *)imageWithSystemName:(NSString *)systemName API_AVAILABLE(ios(13), macosx(13.1)) {
    return [UIImage systemImageNamed:systemName];
}
@end
