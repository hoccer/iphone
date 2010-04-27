//
//  StatusViewController.h
//  Hoccer
//
//  Created by Robert Palmer on 18.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HocItemData;


@interface StatusViewController : UIViewController {
	id delegate;
	IBOutlet UIProgressView *progressView;	
	IBOutlet UIActivityIndicatorView *activitySpinner;
	IBOutlet UILabel *statusLabel;

	IBOutlet UIButton *hintButton;
	IBOutlet UITextView *hintText;
	IBOutlet UIButton *cancelButton;
	
	IBOutlet UIImageView *backgroundImage;
	
	HocItemData *hocItemData;
	
	NSInteger hoccabiliy;
	NSError *badLocationHint;
	
	@private
	BOOL showingError;
}

@property (assign) id delegate;
@property (retain) HocItemData* hocItemData;

- (void)setUpdate: (NSString *)update;
- (void)setError: (NSError *)error;
- (void)setErrorMessage: (NSString *)message;
- (void)setProgressUpdate: (CGFloat) percentage;
- (void)setLocationHint: (NSError *)hint;

- (void)setCompleteState;

- (IBAction) cancelAction: (id) sender;
- (IBAction)toggelRecoveryHelp: (id)sender;

- (void)monitorHocItem: (HocItemData *)hocItem;
@end

