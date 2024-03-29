//
//  SweepOutRecognizer.m
//  Hoccer
//
//  Created by Robert Palmer on 08.04.10.
//  Copyright 2010 Hoccer GmbH AG. All rights reserved.
//

#import "SweepOutRecognizer.h"
#import "DesktopView.h"

#define kSweepBorder 30

@implementation SweepOutRecognizer

@synthesize delegate;
@synthesize sweepDirection;
@synthesize lastTouch;


- (void) dealloc {
	[lastTouch release];
	[super dealloc];
}

- (void)desktopView:(DesktopView *)view touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	self.lastTouch = [touches anyObject];
	CGPoint currentLocation = [lastTouch locationInView:view];

//    NSLog(@"4. SweepOutRecognizer - desktopView touchesBegan  x = %f", currentLocation.x);

    
	if ([view.currentlyTouchedViews count] > 0 && (kSweepBorder < currentLocation.x && currentLocation.x < view.frame.size.width - kSweepBorder)) {
		detecting = YES;
	}
    else {
//        NSLog(@"4. SweepOutRecognizer - desktopView touchesBegan  x = %f", currentLocation.x);
    }
}

- (void)desktopView:(DesktopView *)view touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (!detecting) {
//        NSLog(@"4.a. Out - touchesMoved - detecting = no ");
		return;
	}
//    NSLog(@"4.b. Out - touchesMoved - detecting = yes ");

	self.lastTouch = [touches anyObject];
	CGPoint currentLocation = [lastTouch locationInView: view];
	
	if (!gestureDetected) {
		CGFloat width = view.frame.size.width; 
		if (currentLocation.x < kSweepBorder) {
			self.sweepDirection = kSweepDirectionLeftOut;
			gestureDetected = YES;	
			
			if ([delegate respondsToSelector:@selector(sweepOutRecognizerDidRecognizeSweepOut:)]) {
				[delegate sweepOutRecognizerDidRecognizeSweepOut:self];
			}
		}
        else if (currentLocation.x > width - kSweepBorder ) {
			self.sweepDirection = kSweepDirectionRightOut;
			gestureDetected = YES;	
			
			if ([delegate respondsToSelector:@selector(sweepOutRecognizerDidRecognizeSweepOut:)]) {
				[delegate sweepOutRecognizerDidRecognizeSweepOut:self];
			}		
		}
        else {
//            NSLog(@"4.c. Out - touchesMoved - no left out AND no right out ");
        }
	}
}

- (void)desktopView: (DesktopView *)view touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	if (detecting && !gestureDetected) {
		if ([delegate respondsToSelector:@selector(sweepOutRecognizerDidCancelSweepOut:)]) {
			[delegate sweepOutRecognizerDidCancelSweepOut:self];
		}
	}
	
	gestureDetected = NO;
	detecting = NO;
	self.sweepDirection = kNoSweeping;
}

- (void)desktopView: (DesktopView *)view touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	[self desktopView:view touchesEnded:touches withEvent:event];
}

@end
