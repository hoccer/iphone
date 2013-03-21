//
//  ConnectionStatusViewController.m
//  Hoccer
//
//  Created by Robert Palmer on 02.08.10.
//  Copyright 2010 Hoccer GmbH AG. All rights reserved.
//

#import "ConnectionStatusViewController.h"
#import "ItemViewController.h"
#import "StatusBarStates.h"
#import "HoccerImage.h"

@implementation ConnectionStatusViewController
@synthesize delegate;

- (void)setUpdate: (NSString *)update {
    
	statusLabel.text = update;
	[self calculateHightForText:statusLabel.text];
	[self setState:[[[ConnectionState alloc] init] autorelease]];
}

- (void)setUpdateSending:(NSString *)update {
    
	[self calculateHightForText:statusLabel.text];
    [self setStatusLabelText:update];
	[self setState: [[[SendingState alloc] init] autorelease]];
}

- (void)setProgressUpdate: (CGFloat) percentage {
    if (USES_DEBUG_MESSAGES) { NSLog(@"ConnectionStatusViewController setProgressUpdate %f", percentage);}

	progressView.progress = percentage;    
    [self setStatusLabelText:NSLocalizedString(@"Status_Transferring", nil)];
	[self setState:[TransferState state]];
}

- (IBAction) cancelAction: (id) sender {
	[self hideViewAnimated:YES];
	
	if ([delegate respondsToSelector:@selector(connectionStatusViewControllerDidCancel:)]) {
		[delegate connectionStatusViewControllerDidCancel:self];
	}
}

- (void)setStatusLabelText:(NSString *)text {
    
    float maxBarWidth = 200.0f;
    float paddingBar = 10.0f;
    
    statusLabel.numberOfLines = 1;
    statusLabel.text = text;
    [statusLabel sizeToFit];
    
    CGRect progressFrame = progressView.frame;
    float leftBorder = CGRectGetMaxX(statusLabel.frame) + paddingBar;
    float rightBorder = CGRectGetMaxX(progressFrame);
    if (rightBorder - leftBorder > maxBarWidth) leftBorder = rightBorder - maxBarWidth;
    
    progressFrame.origin.x = leftBorder;
    progressFrame.size.width = rightBorder - leftBorder;
    progressView.frame = progressFrame;
}

@end
