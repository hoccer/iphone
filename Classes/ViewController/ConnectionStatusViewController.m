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
@synthesize content;
- (void) dealloc {
	[content release];
	[super dealloc];
}

- (void)setUpdate: (NSString *)update {
	statusLabel.text = update;
	[self setState: [[[ConnectionState alloc] init] autorelease]];
}

- (void)setProgressUpdate: (CGFloat) percentage {
	progressView.progress = percentage;
	statusLabel.text = @"Transfering";
	[self setState:[TransferState state]];		 
}

- (IBAction) cancelAction: (id) sender {
	// [content cancelRequest];
	self.content = nil;
	
	[self hideViewAnimated:YES];
}

@end
