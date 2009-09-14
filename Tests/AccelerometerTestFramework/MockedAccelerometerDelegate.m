//
//  MockedAccelerometerDelegate.m
//  Hoccer
//
//  Created by Robert Palmer on 14.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "MockedAccelerometerDelegate.h"


@implementation MockedAccelerometerDelegate

@synthesize receivedAccelarations;

- (id) init
{
	self = [super init];
	if (self != nil) {
		receivedAccelarations = [[NSMutableArray alloc] init];
	}
	return self;
}

- (NSInteger) accelerationsCount 
{
	return [receivedAccelarations count];
}


#pragma mark UIAcceleratorDelegate Methods
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration 
{
	[receivedAccelarations addObject:acceleration];
}

@end
