//
//  StatusViewController.m
//  Hoccer
//
//  Created by Robert Palmer on 18.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "StatusViewController.h"
#import "NSObject+DelegateHelper.h"
#import "NSString+Regexp.h"
#import "HocItemData.h"

@interface StatusViewController ()
@property (retain) NSError *badLocationHint;
- (void)showRecoverySuggestion;
- (void)hideRecoverySuggestion;

- (void)setConnectingState;
- (void)setTransferState;
- (void)setErrorState;
- (void)setLocationState;
- (void)hideUpdateState;

- (void)showLocationHint;
- (void)hideLocationHint;

- (void)hideViewAnimated;
- (void)showViewAnimated;

@end


@implementation StatusViewController

@synthesize delegate;
@synthesize hocItemData;
@synthesize badLocationHint;

- (void)viewDidLoad {
	[self hideViewAnimated];
	[self hideRecoverySuggestion];
	self.view.backgroundColor = [UIColor clearColor];
	showingError = NO;
}

- (void)dealloc {
	[statusLabel release];
	[activitySpinner release];
	[progressView release];
	[hocItemData release];
	[hintButton release];
	[cancelButton release];
	[badLocationHint release];
	[backgroundImage release];
	
    [super dealloc];
}

- (void)setHocItemData:(HocItemData *)newHocItem {
	if (hocItemData != newHocItem) {
		[hocItemData removeObserver:self forKeyPath:@"status"];
		[hocItemData removeObserver:self forKeyPath:@"progress"];
		[hocItemData release];
		
		hocItemData = [newHocItem retain]; 
		[self monitorHocItem:hocItemData];
	} 
	
	if (hocItemData == nil) {
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	}
}

- (IBAction) cancelAction: (id) sender {
	[hocItemData cancelRequest];
	self.hocItemData = nil;
	
	[self hideUpdateState];
}

#pragma mark -
#pragma mark Managing Status Bar Size

- (void)showRecoverySuggestion {
	backgroundImage.image = [UIImage imageNamed:@"statusbar_large.png"];
	hintText.hidden = NO;
	
	[UIView beginAnimations:@"growView" context:nil];
	self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, 121);
	[UIView setAnimationDuration:0.2];
	[UIView commitAnimations];
}

- (void)hideRecoverySuggestion {
	backgroundImage.image = [UIImage imageNamed:@"statusbar_small.png"];

	self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, 35); 
	hintText.hidden = YES;
}


- (IBAction)toggelRecoveryHelp: (id)sender {
	if (self.view.frame.size.height > 35) {
		[self hideRecoverySuggestion];
	} else {
		[self showRecoverySuggestion];
	}
}	


#pragma mark -
#pragma mark Managing Hoccability / Location Hints

- (void)setLocationHint: (NSError *)hint {
	NSLog(@"hint: %@", hint);
	self.badLocationHint = hint;
	
	if (hint != nil) {
		[self showLocationHint];
	} else {
		[self hideViewAnimated];
	}
}

- (void)showLocationHint {
	if (self.badLocationHint != nil && self.hocItemData == nil && !showingError	) {
		[self setError:self.badLocationHint];
		[self setLocationState];
	}
}

- (void)hideLocationHint {
	if (self.hocItemData == nil) {
		[self hideLocationHint];
		cancelButton.hidden = NO;
	}
}


#pragma mark -
#pragma mark Managing Updates

- (void)setLocationState {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[self showViewAnimated];
	
	progressView.hidden = YES;
	
	activitySpinner.hidden = YES;
	statusLabel.hidden = NO;
	cancelButton.hidden = YES;
	[cancelButton setImage:[UIImage imageNamed:@"statusbar_icon_cancel.png"] forState: UIControlStateNormal];
	hintButton.hidden = YES;
	
	[self showRecoverySuggestion];
	showingError = NO;
}


- (void)setConnectingState {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	[self showViewAnimated];

	progressView.hidden = YES;
	
	activitySpinner.hidden = NO;
	statusLabel.hidden = NO;
	cancelButton.hidden = NO;
	[cancelButton setImage:[UIImage imageNamed:@"statusbar_icon_cancel.png"] forState: UIControlStateNormal];
	hintButton.hidden = YES;
	
	[self hideRecoverySuggestion];
	showingError = NO;
}

- (void)setTransferState {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

	[self showViewAnimated];

	progressView.hidden = NO;
	activitySpinner.hidden = YES;
	statusLabel.hidden = NO;
	cancelButton.hidden = NO;
	[cancelButton setImage:[UIImage imageNamed:@"statusbar_icon_cancel.png"] forState: UIControlStateNormal];
	hintButton.hidden = YES;
	
	[self hideRecoverySuggestion];
	showingError = NO;
}

- (void)setCompleteState {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	[self showViewAnimated];

	progressView.hidden = YES;
	activitySpinner.hidden = YES;
	statusLabel.hidden = NO;
	cancelButton.hidden = NO;
	[cancelButton setImage:[UIImage imageNamed:@"statusbar_icon_complete.png"] forState: UIControlStateNormal];
	hintButton.hidden = YES;
	
	statusLabel.text = @"Success";
	[self hideRecoverySuggestion];
	
	[NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(hideUpdateState) userInfo:nil repeats:NO];
	
	showingError = NO;
}

- (void)setErrorState {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	[self showViewAnimated];

	progressView.hidden = YES;
	activitySpinner.hidden = YES;
	statusLabel.hidden = NO;
	cancelButton.hidden = NO;
	[cancelButton setImage:[UIImage imageNamed:@"statusbar_icon_cancel.png"] forState: UIControlStateNormal];
	hintButton.hidden = YES;
	
	showingError = YES;
	[self showRecoverySuggestion];
}

- (void)hideUpdateState {
	self.view.hidden = YES;	

	[self showLocationHint];
}


- (void)setUpdate: (NSString *)update {
	statusLabel.text = update;
	[self setConnectingState];
}

- (void)setErrorMessage: (NSString *)message {
	[self setUpdate:message];
	[self setErrorState];
}


- (void)setProgressUpdate: (CGFloat) percentage {
	progressView.progress = percentage;
	if ([hocItemData.status contains:@"Transfering"]) {
		[self setTransferState];		
	} 
}

- (void)setError:(NSError *)error {
	if ([error localizedDescription]) {
		statusLabel.text = [error localizedDescription];
		if ([error localizedRecoverySuggestion]) {
			hintButton.hidden = NO;
			hintText.text = [error localizedRecoverySuggestion];
		}
		
	}

	[self setErrorState];
}


#pragma mark -
#pragma mark Showing and Hiding StatusBar

- (void)showViewAnimated {
	if (!self.view.hidden) {
		return;
	}

	self.view.hidden = NO;
	
	CGFloat currentYPos = self.view.center.y;
	self.view.center = CGPointMake(self.view.center.x, currentYPos - 105);
	[UIView beginAnimations:@"slideDown" context:nil];
	
	self.view.center = CGPointMake(self.view.center.x, currentYPos);
	[UIView setAnimationDuration:0.7];
	[UIView commitAnimations];
}

- (void)hideViewAnimated {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
//	[UIView beginAnimations:@"slideUp" context:nil];
//	self.view.center = CGPointMake(self.view.center.x, self.view.center.y - 105);
//	[UIView setAnimationDuration:0.5];
//	[UIView commitAnimations];
	
	
	self.view.hidden = YES;
}


#pragma mark -
#pragma mark Monitoring Changes

- (void)monitorHocItem: (HocItemData*) hocItem {
	[hocItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
	[hocItem addObserver:self forKeyPath:@"progress" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqual:@"status"]) {
		[self setUpdate: [change objectForKey:NSKeyValueChangeNewKey]];
	}
	
	if ([keyPath isEqual:@"progress"]) {
		[self setProgressUpdate: [[change objectForKey:NSKeyValueChangeNewKey] floatValue]];
	}
}






@end
