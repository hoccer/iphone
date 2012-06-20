//
//  ErrorViewController.h
//  Hoccer
//
//  Created by Philip Brechler on 14.06.12.
//  Copyright (c) 2012 Hoccer GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ErrorViewController : UIViewController {
    
    IBOutlet UILabel *titleLabel;
    IBOutlet UILabel *messageLabel;
    
    NSTimer *timer;

}

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *messageLabel;

- (void)showError:(NSError *)error forSeconds:(NSTimeInterval)time;
- (void)hideViewAnimated:(BOOL)animated;
- (IBAction)hideView:(id)sender;

@end
