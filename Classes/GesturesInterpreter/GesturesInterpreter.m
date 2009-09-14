//
//  GesturesInterpreter.m
//  Hoccer
//
//  Created by Robert Palmer on 14.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "GesturesInterpreter.h"

@implementation GesturesInterpreter

@synthesize delegate;

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration 
{
	// TODO: insert gesture detection magic here!
	if (false) {
		[self.delegate checkAndPerformSelector: @selector(gesturesInterpreter:didDetectGesture:) 
									withObject: self withObject: @"catch"];
	}
}

@end
