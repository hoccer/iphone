//
//  SweepInRecognizer.m
//  Hoccer
//
//  Created by Robert Palmer on 07.04.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "SweepInRecognizer.h"
#import "DesktopView.h"

#define kSweepInBorder 50
#define kSweepAcceptanceDistance 100

@implementation SweepInRecognizer

@synthesize delegate;
@synthesize sweepingDirection;
@synthesize touchPoint;

- (void)desktopView: (DesktopView*)view touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	self.touchPoint = [[touches anyObject] locationInView: view]; 

	if (touchPoint.x < kSweepInBorder) {
		NSLog(@"starting sweep in from left");
		sweepingDirection = kSweepDirectionLeftIn;
	} else if (touchPoint.x > view.frame.size.width - kSweepInBorder){
		NSLog(@"starting sweep in from right");
		sweepingDirection = kSweepDirectionRightIn;
	}
	
	if (sweepingDirection != kNoSweeping) {
		[delegate sweepInRecognizerDidBeginSweeping: self];
	}
	
}

- (void)desktopView: (DesktopView*)view touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {		
}

- (void)desktopView: (DesktopView*)view touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	CGPoint currentLocation = [[touches anyObject] locationInView: view]; 
	if (sweepingDirection == kSweepDirectionLeftIn && currentLocation.x > kSweepAcceptanceDistance || 
		sweepingDirection == kSweepDirectionRightIn && currentLocation.x < view.frame.size. width - kSweepAcceptanceDistance) {
		
		if ([delegate respondsToSelector:@selector(sweepInRecognizerDidRecognizeSweepIn:)]) {
			[delegate sweepInRecognizerDidRecognizeSweepIn:self];
		}
		
		// if (shouldSnapToCenterOnTouchUp) {
		//	[self startMoveToCenterAnimation];
		// }
		
		sweepingDirection = kNoSweeping;
		return;
	}
	
	if (sweepingDirection != kNoSweeping) {
		// [self startMoveOutAnimation: sweepingDirection];
	}
}

- (void)desktopView: (DesktopView*)view touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	sweepingDirection = kNoSweeping;
}




@end
