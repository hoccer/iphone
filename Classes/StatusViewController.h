//
//  StatusViewController.h
//  Hoccer
//
//  Created by Robert Palmer on 18.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HoccerConnectionController;


@interface StatusViewController : UIViewController {
	id delegate;
	IBOutlet UIProgressView *progressView;	
	IBOutlet UIActivityIndicatorView *activitySpinner;
	IBOutlet UILabel *statusLabel;

	IBOutlet UIButton *hintButton;
	IBOutlet UITextView *hintText;
	IBOutlet UIButton *cancelButton;
	
	HoccerConnectionController *hocItemData;
	
	NSError *badLocationHint;
}

@property (assign) id delegate;
@property (retain) HoccerConnectionController* hocItemData;

- (void)setUpdate: (NSString *)update;
- (void)setError: (NSError *)error;
- (void)setErrorMessage: (NSString *)message;
- (void)setProgressUpdate: (CGFloat) percentage;
- (void)showLocationHint: (NSError *)hint;
- (void)showActivityInfo;
- (void)hideActivityInfo;

- (IBAction) cancelAction: (id) sender;
- (IBAction)toggelRecoveryHelp: (id)sender;

- (void)monitorHocItem: (HoccerConnectionController *)hocItem;
@end

