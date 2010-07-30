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
#import "HoccerController.h"

@interface StatusViewController ()
@property (retain) NSError *badLocationHint;
- (void)showRecoverySuggestion;
- (void)hideRecoverySuggestion;

- (void)setConnectingState;
- (void)setTransferState;
- (void)setErrorStateWithRecovery: (BOOL)recovery;
- (void)setLocationState;
- (void)hideUpdateState;

- (void)showLocationHint;
- (void)hideLocationHint;

- (void)hideViewAnimated;
- (void)showViewAnimated;

@end


@implementation StatusViewController

@synthesize smallBackground;
@synthesize largeBackground;

@synthesize delegate;
@synthesize hoccerControllerData;
@synthesize badLocationHint;
@synthesize covered;

- (void)viewDidLoad {
	[self hideRecoverySuggestion];
	self.view.backgroundColor = [UIColor clearColor];
	showingError = NO;
	
	self.view.layer.hidden = YES;	
}

- (void)dealloc {
	[statusLabel release];
	[activitySpinner release];
	[progressView release];
	[hoccerControllerData release];
	[hintButton release];
	[cancelButton release];
	[badLocationHint release];
	[backgroundImage release];
	
    [super dealloc];
}

- (void)setHoccerControllerData:(HoccerController *)newHoccerController {
	if (hoccerControllerData != newHoccerController) {
		[hoccerControllerData removeObserver:self forKeyPath:@"statusMessage"];
		[hoccerControllerData removeObserver:self forKeyPath:@"progress"];
		[hoccerControllerData release];
		
		hoccerControllerData = [newHoccerController retain]; 
		[self monitorHoccerController:hoccerControllerData];
		
		statusLabel.text = @"Connecting..";
		[self setConnectingState];
	} 
	
	if (hoccerControllerData == nil) {
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	}
}

- (IBAction) cancelAction: (id) sender {
	[hoccerControllerData cancelRequest];
	self.hoccerControllerData = nil;
	
	[self hideUpdateState];
}


- (void)setCovered:(BOOL)isCovered {
	if (!covered) {
		self.view.hidden = YES;
	} else if (hoccerControllerData != nil || badLocationHint != nil){
		self.view.hidden = NO;
	}
	
	covered = isCovered;
}


#pragma mark -
#pragma mark Managing Status Bar Size

- (void)showRecoverySuggestion {
	backgroundImage.image = self.largeBackground;
	hintText.hidden = NO;
	
	self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, 121);
}

- (void)hideRecoverySuggestion {
	backgroundImage.image = self.smallBackground;

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
	self.badLocationHint = hint;
	
	if (hint != nil) {
		[self showLocationHint];
	} else {
		[self hideLocationHint];
	}
}

- (void)showLocationHint {
	if (self.badLocationHint != nil && self.hoccerControllerData == nil && !showingError) {
		[self setError:self.badLocationHint];
		[self setLocationState];
	}
}

- (void)hideLocationHint {
	if (self.hoccerControllerData == nil) {
		[self hideViewAnimated];
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
	
	[timer invalidate];
	timer = nil;
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
	
	[timer invalidate];
	timer = nil;
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
	
	[timer invalidate];
	timer = nil;
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
	
	timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(hideUpdateState) userInfo:nil repeats:NO];
	
	showingError = NO;
}

- (void)setErrorStateWithRecovery: (BOOL)recovery {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	[self showViewAnimated];

	progressView.hidden = YES;
	activitySpinner.hidden = YES;
	statusLabel.hidden = NO;
	cancelButton.hidden = NO;
	[cancelButton setImage:[UIImage imageNamed:@"statusbar_icon_cancel.png"] forState: UIControlStateNormal];
	hintButton.hidden = YES;
	
	showingError = YES;
	if (recovery) {
		[self showRecoverySuggestion];
	} else {
		[self hideRecoverySuggestion];
	}


	[timer invalidate];
	timer = nil;
}

- (void)hideUpdateState {
	self.view.hidden = YES;	

	[self showLocationHint];
	
	[timer invalidate];
	timer = nil;
}

- (void)setUpdate: (NSString *)update {
	if ([[hoccerControllerData.status objectForKey:@"status_code"] intValue] != 200) {
		statusLabel.text = update;
		[self setConnectingState];
	} 	
}

- (void)setProgressUpdate: (CGFloat) percentage {
	progressView.progress = percentage;
	if ([[hoccerControllerData.status objectForKey:@"status_code"] intValue] == 200) {
		statusLabel.text = @"Transfering";
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

	[self setErrorStateWithRecovery:([error localizedRecoverySuggestion] != nil)];
}


#pragma mark -
#pragma mark Showing and Hiding StatusBar

- (void)showViewAnimated {
	NSLog(@"hidden: %d", self.view.hidden);
	if (!self.view.hidden || self.covered) {
		return;
	}

	self.view.hidden = NO;
	
	CGFloat currentYPos = self.view.center.y;
	NSLog(@"current position: %d", currentYPos);

	self.view.center = CGPointMake(self.view.center.x, currentYPos - 100);
	[UIView beginAnimations:@"slideDown" context:nil];
	
	self.view.center = CGPointMake(self.view.center.x, currentYPos);
	[UIView commitAnimations];
}

- (void)hideViewAnimated {
	NSLog(@"hide animation");
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
	animation.toValue = [NSValue valueWithCGPoint:CGPointMake(self.view.center.x, self.view.center.y - 100)];
	animation.fillMode = kCAFillModeBoth;
	animation.removedOnCompletion = NO;
	animation.duration = 0.2;
	animation.delegate = self;
	
	[self.view.layer addAnimation:animation forKey:@"slideUp"];
	
	// self.view.center = CGPointMake(self.view.center.x, currentYPos);
}

- (void) animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
	NSLog(@"ready");
	self.view.hidden = YES;
	[self.view.layer removeAllAnimations];
}

#pragma mark -
#pragma mark Monitoring Changes

- (void)monitorHoccerController: (HoccerController*) hoccerController {
	[hoccerController addObserver:self forKeyPath:@"statusMessage" options:NSKeyValueObservingOptionNew context:nil];
	[hoccerController addObserver:self forKeyPath:@"progress" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqual:@"statusMessage"]) {
		[self setUpdate: [change objectForKey:NSKeyValueChangeNewKey]];
	}
	
	if ([keyPath isEqual:@"progress"]) {
		[self setProgressUpdate: [[change objectForKey:NSKeyValueChangeNewKey] floatValue]];
	}
}

#pragma mark -
#pragma mark Getters
- (UIImage *) smallBackground {
	if (smallBackground == nil) {
		smallBackground = [[UIImage imageNamed:@"statusbar_small.png"] retain];
	}
	
	return smallBackground;
}

- (UIImage *) largeBackground {
	if (largeBackground == nil) {
		largeBackground = [[UIImage imageNamed:@"statusbar_large.png"] retain];
	}
	
	return largeBackground;
}



@end
