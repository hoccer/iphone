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
#define kSweepAcceptanceDistance 50

@implementation SweepInRecognizer

@synthesize delegate;
@synthesize sweepingDirection;
@synthesize touchPoint;

- (void)desktopView: (DesktopView*)view touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	NSLog(@"touchesBegan");
	self.touchPoint = [[touches anyObject] locationInView: view]; 

	if (touchPoint.x < kSweepInBorder) {
		sweepingDirection = kSweepDirectionLeftIn;
	} else if (touchPoint.x > view.frame.size.width - kSweepInBorder){
		sweepingDirection = kSweepDirectionRightIn;
	}
	
	isSweeping = NO;
	
}

- (void)desktopView: (DesktopView*)view touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {		
	if (sweepingDirection != kNoSweeping && !isSweeping) {
		[delegate sweepInRecognizerDidBeginSweeping: self];
		
		isSweeping = YES;
	}
}

- (void)desktopView: (DesktopView*)view touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	NSLog(@"touchesEnded");

	CGPoint currentLocation = [[touches anyObject] locationInView: view]; 
	if (sweepingDirection == kSweepDirectionLeftIn && currentLocation.x > kSweepAcceptanceDistance || 
		sweepingDirection == kSweepDirectionRightIn && currentLocation.x < view.frame.size. width - kSweepAcceptanceDistance) {
		
		if ([delegate respondsToSelector:@selector(sweepInRecognizerDidRecognizeSweepIn:)]) {
			[delegate sweepInRecognizerDidRecognizeSweepIn:self];
		}
		
		sweepingDirection = kNoSweeping;
		return;
	}
	
	if (sweepingDirection != kNoSweeping) {
		if ([delegate respondsToSelector:@selector(sweepInRecognizerDidCancelSweepIn:)]) {
			[delegate sweepInRecognizerDidCancelSweepIn:self];
		} 
	}
}

- (void)desktopView: (DesktopView*)view touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	NSLog(@"touchesCanceled");

	sweepingDirection = kNoSweeping;
}




@end
