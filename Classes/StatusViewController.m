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
#import "HocItemData.h"

@interface StatusViewController ()
@property (retain) NSError *badLocationHint;
- (void)showRecoverySuggestion;
- (void)hideRecoverySuggestion;

@end


@implementation StatusViewController

@synthesize delegate;
@synthesize hocItemData;
@synthesize badLocationHint;

- (void)viewDidLoad {
	[self hideRecoverySuggestion];
	self.view.backgroundColor = [UIColor clearColor];
	// self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"statusbar_small.png"]];

}

- (void)dealloc {
	[statusLabel release];
	[activitySpinner release];
	[progressView release];
	[hocItemData release];
	[hintButton release];
	[cancelButton release];
	[badLocationHint release];
	
    [super dealloc];
}

- (void)setHocItemData:(HocItemData *)newHocItem {
	if (hocItemData != newHocItem) {
		[hocItemData removeObserver:self forKeyPath:@"status"];
		[hocItemData release];
		
		hocItemData = [newHocItem retain]; 
		[self monitorHocItem:hocItemData];
	} 
	
	if (hocItemData == nil) {
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	}
}

- (IBAction) cancelAction: (id) sender {
	self.view.hidden = YES;	
	
	[hocItemData cancelRequest];
	self.hocItemData = nil;
	
	if (badLocationHint != nil) {
		[self showLocationHint:badLocationHint];
	}
}

- (void)setUpdate: (NSString *)update {
	NSLog(@"setting update");
	progressView.progress = 0;
	progressView.hidden = NO;
	activitySpinner.hidden = NO;
	statusLabel.hidden = NO;
	statusLabel.text = update;
	
	hintButton.hidden = YES;
	cancelButton.hidden = NO;

	[self hideRecoverySuggestion];
}

- (void)setErrorMessage: (NSString *)message {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[self setUpdate:message];
}


- (void)setProgressUpdate: (CGFloat) percentage {
	progressView.hidden = NO;
	progressView.progress = percentage;
}

- (void)showActivityInfo {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

	self.view.hidden = NO;
	
	CGFloat currentYPos = self.view.center.y;
	self.view.center = CGPointMake(self.view.center.x, currentYPos - 35);
	[UIView beginAnimations:@"slideDown" context:nil];
	
	self.view.center = CGPointMake(self.view.center.x, currentYPos);
	[UIView setAnimationDuration:0.2];
	[UIView commitAnimations];
	
	//CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"bounds"];
//	animation.fromValue = [NSValue valueWithCGRect:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, 0)];
//	animation.duration = 0.2;
//	
//    [self.view.layer addAnimation:animation forKey:nil];					   
							
	[activitySpinner startAnimating];
}

- (void)hideActivityInfo {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	self.view.hidden = YES;
	[activitySpinner stopAnimating];
}

- (void)monitorHocItem: (HocItemData*) hocItem {
	[hocItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqual:@"status"]) {
		[self setUpdate: [change objectForKey:NSKeyValueChangeNewKey]];
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
	cancelButton.hidden = NO;
	self.view.hidden = NO;
}

- (void)showLocationHint: (NSError *)hint {
	if (hint != nil) {
		[self setError: hint];
		cancelButton.hidden = YES;
	} else {
		[self hideActivityInfo];
	}

	self.badLocationHint = hint;
}


- (void)showRecoverySuggestion {
	self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, 121);
	hintText.hidden = NO;
}

- (void)hideRecoverySuggestion {
	self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, 35); 
	hintText.hidden = YES;
}


- (IBAction)toggelRecoveryHelp: (id)sender {
	NSLog(@"show help");
	if (self.view.frame.size.height > 35) {
		[self hideRecoverySuggestion];
	} else {
		[self showRecoverySuggestion];
	}
}


#pragma mark -
#pragma mark CALayer Delegate 

//- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
//	NSLog(@"draw layer");
//}



@end
