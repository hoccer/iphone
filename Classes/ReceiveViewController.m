    //
//  ReceiveViewController.m
//  Hoccer
//
//  Created by Robert Palmer on 15.03.10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "ReceiveViewController.h"

#define kSweepInBorder 30


@implementation ReceiveViewController
@synthesize feedback;

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
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
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
	[feedback release];
    [super dealloc];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	CGPoint currentLocation = [[touches anyObject] locationInView: self.view]; 
	
	if (currentLocation.x < kSweepInBorder) {
		NSLog(@"starting sweep in");
		sweeping = YES;
		feedback.hidden = NO;
		feedback.center = CGPointMake(- feedback.frame.size.width / 2 + currentLocation.x, currentLocation.y);
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{	
	CGPoint currentLocation = [[touches anyObject] locationInView: self.view]; 

	if (sweeping) {
		feedback.center = CGPointMake(- feedback.frame.size.width / 2 + currentLocation.x, currentLocation.y);
	}
	
	NSLog(@"touches moved in ReceiveViewController");
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{	
	NSLog(@"touches ended in ReceiveViewController");
	
	sweeping = NO;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
	NSLog(@"touches cancelled in ReceiveViewController");
}

@end
