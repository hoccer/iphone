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

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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
	[self.delegate checkAndPerformSelector:@selector (userDidCancel)];
}

- (void)setUpdate: (NSString *)update
{
	NSLog(@"seting update %@ on %@", update, statusLabel);
	
	
	progressView.progress = 0;
	
	progressView.hidden = NO;
	activitySpinner.hidden = NO;
	statusLabel.hidden = NO;
	statusLabel.text = update;
}

- (void)setProgressUpdate: (CGFloat) percentage
{
	progressView.hidden = NO;
	progressView.progress = percentage;
}

- (void)showActivityInfo
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	self.view.hidden = NO;
	self.view.center = CGPointMake(160, -35);
	
	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
	animation.fromValue = [NSNumber valueWithCGPoint:CGPointMake(160, -35)];
	animation.toValue = [NSNumber valueWithCGPoint: CGPointMake(160, 30)];
	animation.duration = 0.2;	
	animation.fillMode = kCAFillModeForwards;
	animation.removedOnCompletion = NO;
	animation.beginTime = CACurrentMediaTime() + 0.6;
	animation.delegate = self;
	
	[[self.view layer] addAnimation:animation forKey:@"positionAnimation"];  
	
	[activitySpinner startAnimating];
}

- (void)hideActivityInfo
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	self.view.hidden = YES;
	[activitySpinner stopAnimating];
}


@end
