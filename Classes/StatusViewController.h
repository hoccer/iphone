//
//  StatusViewController.h
//  Hoccer
//
//  Created by Robert Palmer on 18.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface StatusViewController : UIViewController {

	id delegate;
	IBOutlet UIProgressView *progressView;	
	IBOutlet UIActivityIndicatorView *activitySpinner;
	IBOutlet UILabel *statusLabel;

}

@property (assign) id delegate;

- (void)setUpdate: (NSString *)update;
- (void)setError: (NSString *)message;
- (void)setProgressUpdate: (CGFloat) percentage;
- (void)showActivityInfo;
- (void)hideActivityInfo;

- (IBAction) cancelAction: (id) sender;

@end

