//
//  StatusViewController.h
//  Hoccer
//
//  Created by Robert Palmer on 18.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HoccerController;


@interface StatusViewController : UIViewController {
	id delegate;
	IBOutlet UIProgressView *progressView;	
	IBOutlet UIActivityIndicatorView *activitySpinner;
	IBOutlet UILabel *statusLabel;

	IBOutlet UIButton *hintButton;
	IBOutlet UITextView *hintText;
	IBOutlet UIButton *cancelButton;
	
	IBOutlet UIImageView *backgroundImage;
	
	UIImage *smallBackground;
	UIImage *largeBackground;
	
	HoccerController *hoccerControllerData;
	
	NSInteger hoccabiliy;
	NSError *badLocationHint;
	
	@private
	BOOL showingError;
	NSTimer *timer;
	BOOL covered;
}

@property (assign) id delegate;

@property (retain) UIImage *smallBackground;
@property (retain) UIImage *largeBackground;

@property (retain) HoccerController* hoccerControllerData;
@property (assign, getter=isCovered) BOOL covered;


- (void)setUpdate: (NSString *)update;
- (void)setError: (NSError *)error;
- (void)setProgressUpdate: (CGFloat) percentage;
- (void)setLocationHint: (NSError *)hint;

- (void)setCompleteState;

- (IBAction) cancelAction: (id) sender;
- (IBAction)toggelRecoveryHelp: (id)sender;

- (void)monitorHoccerController: (HoccerController *)hoccerController;

@end

