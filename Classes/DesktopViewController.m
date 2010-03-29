    //
//  ReceiveViewController.m
//  Hoccer
//
//  Created by Robert Palmer on 15.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "DesktopViewController.h"
#import "NSObject+DelegateHelper.h"
#import "DragAndDropViewController.h"

#define kSweepInBorder 30
#define kSweepAcceptanceDistance 100

#define kSweepDirectionLeftIn -1
#define kNoSweeping 0
#define kSweepDirectionRightIn 1


@implementation DesktopViewController

@synthesize feedback;

@synthesize dataSource;
@synthesize delegate;

@synthesize blocked;
@synthesize shouldSnapToCenterOnTouchUp;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	blocked = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
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
		
		feedback = [[[delegate emptyDragAndDropController] view] retain];
	} else if (initialTouchPoint.x > self.view.superview.frame.size.width - kSweepInBorder){
		NSLog(@"starting sweep in from right");
		sweeping = kSweepDirectionRightIn;

		feedback = [[[delegate emptyDragAndDropController] view] retain];
	}
	
	[self touchesMoved:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {	
	if (blocked) {
		return;
	}
	
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
		
		if (shouldSnapToCenterOnTouchUp) {
			[self startMoveToCenterAnimation];
		}
		
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
	// [self.view addSubview:self.feedback];
	
	feedback.hidden = YES;
	blocked = NO;
}

#pragma mark -
#pragma mark DataSource Methods

- (void)reloadData {
	for (UIView *subview in self.view.subviews) {
		[subview removeFromSuperview];
	}
	
	NSInteger numberOfItems = [dataSource numberOfItems];
	for (NSInteger i = 0; i < numberOfItems; i++) {
		DragAndDropViewController *controller = [dataSource viewControllerAtIndex: i];
		NSLog(@"adding controller: %@", controller);
		[self.view addSubview: controller.view];
	}
	
	
}




@end
