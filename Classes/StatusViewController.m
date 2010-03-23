//
//  StatusViewController.m
//  Hoccer
//
//  Created by Robert Palmer on 18.03.10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "StatusViewController.h"
#import "NSObject+DelegateHelper.h"




@implementation StatusViewController

@synthesize delegate;


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


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
	self.view.center = CGPointMake(160, 32);
	
	[UIView beginAnimations:@"slideIn" context:nil];
	[UIView setAnimationDuration:0.4];
	
	self.view.center = CGPointMake(160, 68);
	// animation.beginTime = CACurrentMediaTime() + 0.6;
	[UIView commitAnimations];
	
	[activitySpinner startAnimating];
}

- (void)hideActivityInfo
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	self.view.hidden = YES;
	[activitySpinner stopAnimating];
}


@end
