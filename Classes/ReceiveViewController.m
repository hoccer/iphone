    //
//  ReceiveViewController.m
//  Hoccer
//
//  Created by Robert Palmer on 15.03.10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "ReceiveViewController.h"
#import "NSObject+DelegateHelper.h"

#define kSweepInBorder 30
#define kSweepAcceptanceDistance 100

#define kSweepDirectionLeftIn -1
#define kNoSweeping 0
#define kSweepDirectionRightIn 1


@implementation ReceiveViewController

@synthesize feedback;
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
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	blocked = NO;
}


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
	if (blocked) {
		return;
	}
	
	initialTouchPoint = [[touches anyObject] locationInView: self.view]; 

	if (initialTouchPoint.x < kSweepInBorder) {
		NSLog(@"starting sweep in from left");
		sweeping = kSweepDirectionLeftIn;
		feedback.hidden = NO;
		
	} else if (initialTouchPoint.x > self.view.superview.frame.size.width - kSweepInBorder){
		NSLog(@"starting sweep in from right");
		sweeping = kSweepDirectionRightIn;
		feedback.hidden = NO;
	}
	
	[self touchesMoved:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {	
	CGPoint currentLocation = [[touches anyObject] locationInView: self.view]; 

	if (sweeping != kNoSweeping) {
		feedback.center = CGPointMake(sweeping * feedback.frame.size.width / 2 + currentLocation.x, currentLocation.y);
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{	
	NSLog(@"touches ended in ReceiveViewController");
	CGPoint currentLocation = [[touches anyObject] locationInView: self.view]; 

	if (sweeping == kSweepDirectionLeftIn && currentLocation.x > kSweepAcceptanceDistance || 
			sweeping == kSweepDirectionRightIn && currentLocation.x < self.view.frame.size. width - kSweepAcceptanceDistance) {
		
		[self.delegate checkAndPerformSelector:@selector(sweepInterpreterDidDetectSweepIn) withObject:self];
		[self startMoveToCenterAnimation];
		sweeping = kNoSweeping;
		blocked = YES;
		return;
	}
	
	if (sweeping != kNoSweeping) {
		[self startMoveOutAnimation: sweeping];
	}

}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	sweeping = kNoSweeping;
}

- (void)startMoveToCenterAnimation {
	[UIView beginAnimations:@"myFlyInAnimation" context:NULL];
	[UIView setAnimationDuration:0.5];
	feedback.center = CGPointMake(feedback.superview.frame.size.width / 2, feedback.frame.size.height / 2 + 105);

	[UIView commitAnimations];
}

- (void)startMoveOutAnimation: (NSInteger)direction {
	[UIView beginAnimations:@"myFlyOutAnimation" context:NULL];
	[UIView setAnimationDuration:0.5];
	feedback.center = CGPointMake(initialTouchPoint.x + direction * feedback.frame.size.width, initialTouchPoint.y);
	
	[UIView commitAnimations];
}

-  (void)resetView {
	feedback.hidden = YES;
	blocked = NO;
}


@end
