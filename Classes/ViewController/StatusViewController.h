//
//  StatusViewController.h
//  Hoccer
//
//  Created by Robert Palmer on 18.03.10.
//  Copyright 2010 Hoccer GmbH AG. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ItemViewController;
@class StatusViewControllerState;


@interface StatusViewController : UIViewController {
	IBOutlet UIProgressView *progressView;	
	IBOutlet UILabel *statusLabel;
	IBOutlet UILabel *ETALabel;
	IBOutlet UIButton *hintButton;
	IBOutlet UIButton *cancelButton;
	IBOutlet UIImageView *backgroundImage;
		
	NSInteger hoccabiliy;
	NSError *badLocationHint;
    NSDate *lastProgressTime;
    CGFloat lastProgress;
	
	@private
	UIImage *smallBackground;
	UIImage *largeBackground;
	
	NSTimer *timer;
	BOOL cancelable;
}

@property (retain, nonatomic) UIImage *smallBackground;
@property (retain, nonatomic) UIImage *largeBackground;
@property (retain) NSDate *lastProgressTime;
@property (retain) IBOutlet UILabel *statusLabel;
@property CGFloat lastProgress;


- (void)setState: (StatusViewControllerState *)state;
- (void)setError: (NSError *)error;
- (void)setBlockingError: (NSError *)error;
- (void)setLocationHint: (NSError *)hint;

- (void)showMessage: (NSString *)message forSeconds: (NSInteger)seconds;

- (IBAction)cancelAction: (id) sender;

- (BOOL)visible;

- (void)hideViewAnimated: (BOOL)animation;
- (void)showViewAnimated: (BOOL)animation;

- (void)hideStatus;
- (void)calculateHightForText: (NSString *)text;

@end

