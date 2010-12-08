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

- (void)setContent:(HoccerContent *)newContent {
	if (content != newContent) {
		[content removeObserver:self forKeyPath:@"progress"];
		[content removeObserver:self forKeyPath:@"error"];
		[content release];
		
		content = [newContent retain]; 
		[self monitorContent:content];
		
		statusLabel.text = NSLocalizedString(@"Connecting..", nil);
		[self setState:[[[ConnectionState alloc] init] autorelease]];
	} 
	
	if (content == nil) {
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	}
}


- (void) dealloc {
	[content release];
	[super dealloc];
}

- (void)setUpdate: (NSString *)update {
//	if ([[content.status objectForKey:@"status_code"] intValue] != 200) {
//		statusLabel.text = update;
//		[self setState: [[[ConnectionState alloc] init]autorelease]];
//	} 	
}

- (void)setProgressUpdate: (CGFloat) percentage {
	progressView.progress = percentage;
//	if ([[content.status objectForKey:@"status_code"] intValue] == 200) {
//		statusLabel.text = @"Transfering";
//		[self setState:[TransferState state]];		
//	} 
}




- (IBAction) cancelAction: (id) sender {
	// [content cancelRequest];
	self.content = nil;
	
	[self hideViewAnimated:YES];
}

#pragma mark -
#pragma mark Monitoring Changes

- (void)monitorContent: (HoccerContent *)theContent {
	if (![theContent isKindOfClass:[HoccerImage class]]) {
		return;
	}
	
	[theContent addObserver:self forKeyPath:@"error" options:NSKeyValueObservingOptionNew context:nil];
	[theContent addObserver:self forKeyPath:@"progress" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	NSLog(@"updated %@", change);
	
	if ([keyPath isEqual:@"error"]) {
		[self setError: [change objectForKey:NSKeyValueChangeNewKey]];
	}
	
	if ([keyPath isEqual:@"progress"]) {
		[self setProgressUpdate: [[change objectForKey:NSKeyValueChangeNewKey] floatValue]];
	}
}

@end
