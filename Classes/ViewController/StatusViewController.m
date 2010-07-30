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

#import "StatusBarStates.h"


@interface StatusViewController ()
@property (retain) NSError *badLocationHint;
- (void)showRecoverySuggestion;
- (void)hideRecoverySuggestion;

- (void)hideUpdateState;

- (void)showLocationHint;
- (void)hideLocationHint;

@end


@implementation StatusViewController

@synthesize smallBackground;
@synthesize largeBackground;

@synthesize delegate;
@synthesize hoccerController;
@synthesize badLocationHint;
@synthesize hidden;

- (void)viewDidLoad {
	[self hideRecoverySuggestion];
	self.view.backgroundColor = [UIColor clearColor];
	
	self.view.layer.hidden = YES;	
}

- (void)dealloc {
	[statusLabel release];
	[progressView release];
	[hoccerController release];
	[hintButton release];
	[cancelButton release];
	[badLocationHint release];
	[backgroundImage release];
	
    [super dealloc];
}

- (void)setHoccerController:(HoccerController *)newHoccerController {
	if (hoccerController != newHoccerController) {
		[hoccerController removeObserver:self forKeyPath:@"statusMessage"];
		[hoccerController removeObserver:self forKeyPath:@"progress"];
		[hoccerController release];
		
		hoccerController = [newHoccerController retain]; 
		[self monitorHoccerController:hoccerController];
		
		statusLabel.text = @"Connecting..";
		[self setState:[[[ConnectionState alloc] init] autorelease]];
	} 
	
	if (hoccerController == nil) {
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	}
}

- (IBAction) cancelAction: (id) sender {
	[hoccerController cancelRequest];
	self.hoccerController = nil;
	
	[self hideUpdateState];
}


- (void)setHidden:(BOOL)isHidden {
	if (!hidden) {
		self.view.hidden = YES;
	} else if (hoccerController != nil || badLocationHint != nil){
		self.view.hidden = NO;
	}
	
	hidden = isHidden;
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
	if (self.badLocationHint != nil) {
		[self setError:self.badLocationHint];
		[self showViewAnimated: YES];
	}
}

- (void)hideLocationHint {
	if (self.hoccerController == nil) {
		[self hideViewAnimated: YES];
		cancelButton.hidden = NO;
	}
}


#pragma mark -
#pragma mark Managing Updates

- (void)setState: (StatusViewControllerState *)state {
	[self showViewAnimated: YES];
	
	progressView.hidden = state.progressView;
 	statusLabel.hidden = state.statusLabel;
	cancelButton.hidden = state.cancelButton;
	hintButton.hidden = state.hintButton;
	
	if (state.recoverySuggestion) {
		[self showRecoverySuggestion];	
	} else{
		[self hideRecoverySuggestion];
	}
		
	[cancelButton setImage:state.cancelButtonImage forState: UIControlStateNormal];
	
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

- (void)setError:(NSError *)error {
	if ([error localizedDescription]) {
		statusLabel.text = [error localizedDescription];
		if ([error localizedRecoverySuggestion]) {
			hintButton.hidden = NO;
			hintText.text = [error localizedRecoverySuggestion];
		}
	}

	[self setState:[ErrorState stateWithRecovery:([error localizedRecoverySuggestion] != nil)]];
}


#pragma mark -
#pragma mark Showing and Hiding StatusBar


- (void)showViewAnimated: (BOOL)animation {
	if (!self.view.hidden || self.hidden) {
		return;
	}

	self.view.hidden = NO;
	
	if (animation) {
		CGFloat currentYPos = self.view.center.y;
		
		self.view.center = CGPointMake(self.view.center.x, currentYPos - 100);
		[UIView beginAnimations:@"slideDown" context:nil];
		self.view.center = CGPointMake(self.view.center.x, currentYPos);
		[UIView commitAnimations];	
	}
}

- (void)hideViewAnimated: (BOOL)animation {	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	
	if (animation) {
		CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
		animation.toValue = [NSValue valueWithCGPoint:CGPointMake(self.view.center.x, self.view.center.y - 100)];
		animation.fillMode = kCAFillModeBoth;
		animation.removedOnCompletion = NO;
		animation.duration = 0.2;
		animation.delegate = self;
		
		[self.view.layer addAnimation:animation forKey:@"slideUp"];		
	} else {
		self.view.hidden = YES;
	}
}

- (void) animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
	self.view.hidden = YES;
	[self.view.layer removeAllAnimations];
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
