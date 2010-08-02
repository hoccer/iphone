//
//  ConnectionStatusViewController.m
//  Hoccer
//
//  Created by Robert Palmer on 02.08.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "ConnectionStatusViewController.h"
#import "HoccerController.h"
#import "StatusBarStates.h"

@implementation ConnectionStatusViewController
@synthesize hoccerController;

- (void)setHoccerController:(HoccerController *)newHoccerController {
	if (hoccerController != newHoccerController) {
		[hoccerController removeObserver:self forKeyPath:@"statusMessage"];
		[hoccerController removeObserver:self forKeyPath:@"progress"];
		[hoccerController release];
		
		hoccerController = [newHoccerController retain]; 
		[self monitorHoccerController:hoccerController];
		
		statusLabel.text = NSLocalizedString(@"Connecting..", nil);
		[self setState:[[[ConnectionState alloc] init] autorelease]];
	} 
	
	if (hoccerController == nil) {
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	}
}


- (void) dealloc {
	[hoccerController release];
	[super dealloc];
}


- (void)setUpdate: (NSString *)update {
	if ([[hoccerController.status objectForKey:@"status_code"] intValue] != 200) {
		statusLabel.text = update;
		[self setState: [[[ConnectionState alloc] init]autorelease]];
	} 	
}

- (void)setProgressUpdate: (CGFloat) percentage {
	progressView.progress = percentage;
	if ([[hoccerController.status objectForKey:@"status_code"] intValue] == 200) {
		statusLabel.text = @"Transfering";
		[self setState:[TransferState state]];		
	} 
}


- (IBAction) cancelAction: (id) sender {
	[hoccerController cancelRequest];
	self.hoccerController = nil;
	
	[self hideViewAnimated:YES];
}

#pragma mark -
#pragma mark Monitoring Changes

- (void)monitorHoccerController: (HoccerController*) theHoccerController {
	[theHoccerController addObserver:self forKeyPath:@"statusMessage" options:NSKeyValueObservingOptionNew context:nil];
	[theHoccerController addObserver:self forKeyPath:@"progress" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqual:@"statusMessage"]) {
		[self setUpdate: [change objectForKey:NSKeyValueChangeNewKey]];
	}
	
	if ([keyPath isEqual:@"progress"]) {
		[self setProgressUpdate: [[change objectForKey:NSKeyValueChangeNewKey] floatValue]];
	}
}

@end
