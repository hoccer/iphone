//
//  ConnectionStatusViewController.m
//  Hoccer
//
//  Created by Robert Palmer on 02.08.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
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
	[self setState: [[[ConnectionState alloc] init] autorelease]];
}

- (void)setProgressUpdate: (CGFloat) percentage {
	progressView.progress = percentage;
	statusLabel.text = @"Transferring";
	[self setState:[TransferState state]];		 
}

- (IBAction) cancelAction: (id) sender {
	[self hideViewAnimated:YES];
	
	if ([delegate respondsToSelector:@selector(connectionStatusViewControllerDidCancel:)]) {
		[delegate connectionStatusViewControllerDidCancel:self];
	}
}

@end
