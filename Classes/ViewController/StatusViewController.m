//
//  StatusViewController.m
//  Hoccer
//
//  Created by Robert Palmer on 18.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "StatusViewController.h"
#import "NSString+Regexp.h"

#import "StatusBarStates.h"


@interface StatusViewController ()
@property (retain) NSError *badLocationHint;
- (void)showRecoverySuggestion;
- (void)hideRecoverySuggestion;

- (void)showLocationHint;

@end


@implementation StatusViewController

@synthesize smallBackground;
@synthesize largeBackground;

@synthesize statusLabel;

@synthesize badLocationHint;
@synthesize hidden;

- (void)viewDidLoad {
	[self hideRecoverySuggestion];
	self.view.backgroundColor = [UIColor clearColor];
	
	self.view.layer.hidden = YES;	
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[self cancelAction:self];
}

- (void)dealloc {
	[statusLabel release];
	[progressView release];
	[hintButton release];
	[cancelButton release];
	[badLocationHint release];
	[backgroundImage release];
	
    [super dealloc];
}

- (IBAction) cancelAction: (id) sender {
	[self hideViewAnimated:YES];
}

- (void)setHidden:(BOOL)isHidden {
	if (!hidden) {
		self.view.hidden = YES;
	} else if (badLocationHint != nil){
		self.view.hidden = NO;
	}
	
	hidden = isHidden;
}


#pragma mark -
#pragma mark Managing Status Bar Size

- (void)showRecoverySuggestion {
	backgroundImage.image = self.largeBackground;
	hintText.hidden = NO;

	statusLabel.frame = CGRectMake(statusLabel.frame.origin.x, 2, statusLabel.frame.size.width, statusLabel.frame.size.height);
	self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, 121);
}

- (void)hideRecoverySuggestion {
	backgroundImage.image = self.smallBackground;
	self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, 35); 

	statusLabel.frame = CGRectMake(statusLabel.frame.origin.x, 1, statusLabel.frame.size.width, statusLabel.frame.size.height);
	hintText.hidden = YES;
}

- (IBAction)toggelRecoveryHelp: (id)sender {
	if (self.view.frame.size.height > 35) {
		[self hideRecoverySuggestion];
	} else {
		[self showRecoverySuggestion];
	}
}	

- (void)showMessage: (NSString *)message forSeconds: (NSInteger)seconds; {
	self.statusLabel.text = message;
	if (timer != nil) {
		[timer invalidate];
		[timer release];
	}
	
	timer = [[NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(hideStatus) userInfo:nil repeats:NO] retain];
}

- (void)hideStatus {
	[self hideViewAnimated:YES];
}


#pragma mark -
#pragma mark Managing Hoccability / Location Hints

- (void)setLocationHint: (NSError *)hint {
	self.badLocationHint = hint;
	
	if (hint != nil) {
		[self showLocationHint];
	} else {
		[self hideViewAnimated:YES];
	}
}

- (void)showLocationHint {
	if (self.badLocationHint != nil) {
		[self setError:self.badLocationHint];
		[self showViewAnimated: YES];
	}
}


#pragma mark -
#pragma mark Managing Updates

- (void)setState: (StatusViewControllerState *)state {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = state.activitySpinner;
	
	[self showViewAnimated: YES];
	
	progressView.hidden = state.progressView;
 	statusLabel.hidden = state.statusLabel;
	cancelButton.hidden = state.cancelButton;
	hintButton.hidden = state.hintButton;
	
//	if (state.recoverySuggestion) {
//		[self showRecoverySuggestion];	
//	} else{
//		[self hideRecoverySuggestion];
//	}
		
	[cancelButton setImage:state.cancelButtonImage forState: UIControlStateNormal];
	
	[timer invalidate];
	[timer release];
	timer = nil;
}

- (void)hideUpdateState {
	self.view.hidden = YES;	

	[self showLocationHint];
	
	[timer invalidate];
	[timer release];
	timer = nil;
}

- (void)setError:(NSError *)error {
	CGSize size = CGSizeMake(statusLabel.frame.size.width, CGFLOAT_MAX);
	CGSize errorMessageSize = [[error localizedDescription] sizeWithFont:statusLabel.font constrainedToSize: size];
	
	backgroundImage.hidden = YES;
	CGRect frame = self.view.frame;
	frame.size.height = errorMessageSize.height + 7;
//	frame.origin.y = errorMessageSize.height - self.largeBackground.size.height;
	self.view.frame = frame;
	self.view.backgroundColor = [UIColor colorWithPatternImage:self.largeBackground];
	
	hintText.hidden = NO;
	
	statusLabel.frame = CGRectMake(statusLabel.frame.origin.x, 2, statusLabel.frame.size.width, errorMessageSize.height);
	statusLabel.numberOfLines = 4; 
	
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
