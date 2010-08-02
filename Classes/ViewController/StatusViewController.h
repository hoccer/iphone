//
//  StatusViewController.h
//  Hoccer
//
//  Created by Robert Palmer on 18.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HoccerController;
@class StatusViewControllerState;


@interface StatusViewController : UIViewController {
	IBOutlet UIProgressView *progressView;	
	IBOutlet UILabel *statusLabel;
	IBOutlet UIButton *hintButton;
	IBOutlet UITextView *hintText;
	IBOutlet UIButton *cancelButton;
	IBOutlet UIImageView *backgroundImage;
		
	NSInteger hoccabiliy;
	NSError *badLocationHint;
	
	@private
	UIImage *smallBackground;
	UIImage *largeBackground;
	
	NSTimer *timer;
	BOOL hidden;
}

@property (retain) UIImage *smallBackground;
@property (retain) UIImage *largeBackground;
@property (retain) IBOutlet UILabel *statusLabel;

@property (assign, getter=isHidden) BOOL hidden;

- (void)setState: (StatusViewControllerState *)state;
- (void)setError: (NSError *)error;
- (void)setLocationHint: (NSError *)hint;

- (void)showMessage: (NSString *)message forSeconds: (NSInteger)seconds;

- (IBAction)cancelAction: (id) sender;
- (IBAction)toggelRecoveryHelp: (id)sender;

- (void)hideViewAnimated: (BOOL)animation;
- (void)showViewAnimated: (BOOL)animation;

@end

