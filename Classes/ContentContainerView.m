//
//  ContentContainerView.m
//  Hoccer
//
//  Created by Robert Palmer on 31.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "ContentContainerView.h"
#import "NSObject+DelegateHelper.h"

#define kSweepBorder 50

@implementation ContentContainerView

@synthesize delegate;
@synthesize origin;
@synthesize containedView;

- (id) initWithView: (UIView *)subview
{
	self = [super initWithFrame:subview.frame];
	if (self != nil) {
		containedView = [subview retain];
		
		subview.center = CGPointMake(subview.frame.size.width / 2, subview.frame.size.height / 2);
		[self addSubview:subview];
		
		button = [UIButton buttonWithType:UIButtonTypeCustom];
		
		NSString *closeButtonPath = [[NSBundle mainBundle] pathForResource:@"Close" ofType:@"png"];
		[button setImage:[UIImage imageWithContentsOfFile:closeButtonPath] forState:UIControlStateNormal];
		
		NSString *highlightedCloseButtonPath = [[NSBundle mainBundle] pathForResource:@"Close_Highlighted" ofType:@"png"];
		[button setImage:[UIImage imageWithContentsOfFile:highlightedCloseButtonPath] 
				forState:UIControlStateHighlighted];
		
		[button setFrame: CGRectMake(3, 3, 35, 36)];
		
		[self addSubview: button];
	}
	return self;
}

- (void) dealloc
{
	[containedView release];
	[button release];
	
	[super dealloc];
}



- (void) setCloseActionTarget: (id) aTarget action: (SEL) aSelector{
	[button addTarget: aTarget action: aSelector forControlEvents:UIControlEventTouchUpInside];
}

- (void)setOrigin:(CGPoint)newOrigin {
	CGRect frame = self.frame;
	frame.origin = newOrigin;
	self.frame = frame;
}


#pragma mark -
#pragma mark Touch Event
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	NSLog(@"touches began");
	touchStartPoint = [[touches anyObject]locationInView: self.superview];	
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{	

	UITouch* touch = [touches anyObject];
	CGPoint prevLocation = [touch previousLocationInView: self.superview];
	CGPoint currentLocation = [touch locationInView: self.superview];
	
	NSLog(@"touches moved: %f, %f", currentLocation.x, currentLocation.y);

	CGRect myRect = self.frame;
	myRect.origin.x += currentLocation.x - prevLocation.x; 
	myRect.origin.y += currentLocation.y - prevLocation.y; 
	
	self.frame = myRect;
	
	[delegate containerView:self didMoveToPosition:self.frame.origin];
	
	if (!gestureDetected) {
		CGFloat width = self.superview.frame.size.width; 
		if (currentLocation.x < kSweepBorder) {
			CGFloat height = currentLocation.y - [touch locationInView:self].y;
			[self startFlySidewaysAnimation: CGPointMake(-width, height)];
			gestureDetected = YES;	
			
			[self.delegate checkAndPerformSelector:@selector(sweepInterpreterDidDetectSweepOut:) withObject: self];
		} else if (currentLocation.x > width - kSweepBorder ) {
			CGFloat height = currentLocation.y - [touch locationInView:self].y;

			[self startFlySidewaysAnimation: CGPointMake(width, height)];
			gestureDetected = YES;	
			
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

#pragma mark -
#pragma mark animations
- (void)startFlyOutUpwardsAnimation
{
	[UIView beginAnimations:@"myFlyOutUpwardsAnimation" context:NULL];
	[UIView setAnimationDuration:0.2];
	CGRect myRect = self.frame;
	myRect.origin = CGPointMake(origin.x, -200);
	
	self.frame = myRect;
	[UIView commitAnimations];
}

- (void)startFlySidewaysAnimation: (CGPoint) endPoint
{
	CGRect myRect = self.frame;
	myRect.origin = endPoint;
	
	[UIView beginAnimations:@"myFlyOutSidewaysAnimation" context:NULL];
	[UIView setAnimationDuration:0.3];	
	self.frame = myRect;
	[UIView commitAnimations];
}

- (void)resetViewAnimated: (BOOL)animated {
	CGRect myRect = self.frame;
	myRect.origin = origin;
	
	self.frame = myRect;
	self.userInteractionEnabled = YES;
}



@end
