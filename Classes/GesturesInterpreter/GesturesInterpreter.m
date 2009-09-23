//
//  GesturesInterpreter.m
//  Hoccer
//
//  Created by Robert Palmer on 14.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "GesturesInterpreter.h"
#import "NSObject+DelegateHelper.h"
#import "CatchDetector.h"
#import "FeatureHistory.h"


@implementation GesturesInterpreter


@synthesize delegate;

- (id) init
{
	self = [super init];
	if (self != nil) {
		catchDetector = [[CatchDetector alloc] init];
		featureHistory = [[FeatureHistory alloc] init];
		
		[UIAccelerometer sharedAccelerometer].delegate = self;
		[UIAccelerometer sharedAccelerometer].updateInterval = 0.02;

		
		
	}
	return self;
}

- (void)dealloc 
{
	[UIAccelerometer sharedAccelerometer].delegate = nil;
	
	[featureHistory release];
	[catchDetector release];

	[super dealloc];
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration 
{
	[featureHistory addAcceleration:acceleration];
	
	if ([catchDetector detect:featureHistory]) {
		[self.delegate checkAndPerformSelector: @selector(gesturesInterpreter:didDetectGesture:) 
									withObject: self withObject: @"catch"];
	}
}

@end
