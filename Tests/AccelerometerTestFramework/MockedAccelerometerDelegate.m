//
//  MockedAccelerometerDelegate.m
//  Hoccer
//
//  Created by Robert Palmer on 14.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "MockedAccelerometerDelegate.h"


@implementation MockedAccelerometerDelegate

@synthesize accelerationsCount;

- (id) init
{
	self = [super init];
	if (self != nil) {
		accelerationsCount = 0;
	}
	return self;
}


- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration 
{
	accelerationsCount += 1;
}


@end
