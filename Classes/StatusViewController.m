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

@implementation StatusViewController

@synthesize delegate;

- (void)dealloc {
	[statusLabel release];
	[activitySpinner release];
	[progressView release];
    [super dealloc];
}

- (IBAction) cancelAction: (id) sender{
	self.view.hidden = YES;	
	[self.delegate checkAndPerformSelector:@selector(statusViewControllerDidCancelRequest:) withObject:self];
}

- (void)setUpdate: (NSString *)update
{
	progressView.progress = 0;
	progressView.hidden = NO;
	activitySpinner.hidden = NO;
	statusLabel.hidden = NO;
	statusLabel.text = update;
}

- (void)setError: (NSString *)message {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[self setUpdate:message];
}


- (void)setProgressUpdate: (CGFloat) percentage {
	progressView.hidden = NO;
	progressView.progress = percentage;
}

- (void)showActivityInfo
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	self.view.hidden = NO;
	self.view.center = CGPointMake(self.view.superview.frame.size.width / 2, 32);
	
	[UIView beginAnimations:@"slideIn" context:nil];
	[UIView setAnimationDuration:0.4];
	
	self.view.center = CGPointMake(self.view.superview.frame.size.width / 2, 68);
	[UIView commitAnimations];
	
	[activitySpinner startAnimating];
}

- (void)hideActivityInfo
{
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


@end
