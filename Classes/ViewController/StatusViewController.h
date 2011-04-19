//
//  StatusViewController.h
//  Hoccer
//
//  Created by Robert Palmer on 18.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ItemViewController;
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
	BOOL cancelable;
}

@property (retain, nonatomic) UIImage *smallBackground;
@property (retain, nonatomic) UIImage *largeBackground;
@property (retain) IBOutlet UILabel *statusLabel;

@property (assign, nonatomic, getter=isHidden) BOOL hidden;

- (void)setState: (StatusViewControllerState *)state;
- (void)setError: (NSError *)error;
- (void)setBlockingError: (NSError *)error;
- (void)setLocationHint: (NSError *)hint;

- (void)showMessage: (NSString *)message forSeconds: (NSInteger)seconds;

- (IBAction)cancelAction: (id) sender;
- (IBAction)toggelRecoveryHelp: (id)sender;

- (void)hideViewAnimated: (BOOL)animation;
- (void)showViewAnimated: (BOOL)animation;

- (void)hideStatus;
- (void)calculateHightForText: (NSString *)text;

@end

