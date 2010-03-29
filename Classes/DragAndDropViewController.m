    //
//  PreviewViewController.m
//  Hoccer
//
//  Created by Robert Palmer on 15.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "DragAndDropViewController.h"
#import "Preview.h"
#import "NSObject+DelegateHelper.h"

#define kSweepBorder 50

@implementation DragAndDropViewController

@synthesize origin;
@synthesize delegate;
@synthesize shouldSnapBackOnTouchUp;
@synthesize content;
@synthesize requestStamp;

- (id) init {
	self = [super init];
	if (self){
		self.view = [[UIView alloc] initWithFrame:CGRectMake(0,0, 150, 150)];
		self.view.backgroundColor = [UIColor whiteColor];
		gestureDetected = FALSE;
		self.requestStamp = [NSDate timeIntervalSinceReferenceDate];
	}
	return self;	
}

- (void) dealloc {
	[content release];
	[super dealloc];
}

- (void)setContent:(id <HoccerContent>)theContent {
	if (theContent != content) {
		[content release];
		content = [theContent retain];

		[self setView:[content thumbnailView]];
	}
}


- (void) setView:(UIView *) aPreview {
	super.view = aPreview;
	 
	if ([self.view isKindOfClass: [Preview class]]) {
		[(Preview*) self.view setCloseActionTarget:self action:@selector(userDismissedContent:)];
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	NSLog(@"touches began");
	touchStartPoint = [[touches anyObject]locationInView: self.view.superview];	
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{	

	UITouch* touch = [touches anyObject];
	CGPoint prevLocation = [touch previousLocationInView: self.view.superview];
	CGPoint currentLocation = [touch locationInView: self.view.superview];
	
	NSLog(@"touches moved: %f, %f", currentLocation.x, currentLocation.y);

	CGRect myRect = self.view.frame;
	myRect.origin.x += currentLocation.x - prevLocation.x; 
	myRect.origin.y += currentLocation.y - prevLocation.y; 
	
	self.view.frame = myRect;
	
	if (!gestureDetected) {
		CGFloat width = self.view.superview.frame.size.width; 
		NSLog(@"width: %f", width);
		if (currentLocation.x < kSweepBorder) {
			CGFloat height = currentLocation.y - [touch locationInView:self.view].y;
			[self startFlySidewaysAnimation: CGPointMake(-width, height)];
			gestureDetected = YES;	
			
			NSLog(@"delegate: %@", self.delegate);
			[self.delegate checkAndPerformSelector:@selector(sweepInterpreterDidDetectSweepOut:) withObject: self];
		} else if (currentLocation.x > width - kSweepBorder ) {
			CGFloat height = currentLocation.y - [touch locationInView:self.view].y;

			[self startFlySidewaysAnimation: CGPointMake(width, height)];
			gestureDetected = YES;	
			
			NSLog(@"delegate: %@", self.delegate);
			[self.delegate checkAndPerformSelector:@selector(sweepInterpreterDidDetectSweepOut:) withObject: self];
		}
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{	
	if (!gestureDetected && shouldSnapBackOnTouchUp) {
		[self resetViewAnimated:YES];
	}
	
	gestureDetected = NO;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
	gestureDetected = NO;
}

- (void)dismissKeyboard
{
	for (UIView* view in self.view.subviews) {
		if ([view isKindOfClass:[UITextView class]])
			[view resignFirstResponder];
	}
}

- (void)resetViewAnimated: (BOOL)animated {
	CGRect myRect = self.view.frame;
	myRect.origin = origin;
		
	self.view.frame = myRect;
	self.view.userInteractionEnabled = YES;
}

- (void)setOrigin: (CGPoint)newOrigin {
	origin = newOrigin;
	[self resetViewAnimated: NO];
}

- (void)userDismissedContent: (id)sender
{
	[self.delegate checkAndPerformSelector: @selector(dragAndDropViewControllerWillBeDismissed:) withObject: self];
}

#pragma mark -
#pragma mark animations
- (void)startFlyOutUpwardsAnimation
{
	[UIView beginAnimations:@"myFlyOutUpwardsAnimation" context:NULL];
	[UIView setAnimationDuration:0.2];
	CGRect myRect = self.view.frame;
	myRect.origin = CGPointMake(origin.x, -200);
	
	self.view.frame = myRect;
	[UIView commitAnimations];
}

- (void)startFlySidewaysAnimation: (CGPoint) endPoint
{
	CGRect myRect = self.view.frame;
	myRect.origin = endPoint;
		
	[UIView beginAnimations:@"myFlyOutSidewaysAnimation" context:NULL];
	[UIView setAnimationDuration:0.3];	
	self.view.frame = myRect;
	[UIView commitAnimations];
}

@end
