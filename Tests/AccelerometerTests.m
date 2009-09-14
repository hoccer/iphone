//
//  AccelerometerTest.m
//  Hoccer
//
//  Created by Robert Palmer on 14.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "AccelerometerTests.h"
#import "MockedAccelerometerDelegate.h"
#import "UIAccelerometer+TestPlayback.h"

@implementation AccelerometerTests

- (void) setUp 
{
	NSLog(@"setting up accelerometer test");
	accelerometer = [UIAccelerometer sharedAccelerometer];
	STAssertNotNil(accelerometer, @"shared accelerometer should be available");
}

- (void)tearDown 
{
	NSLog(@"tearing down accelerometer test");
}

- (void)testAccelerometerPlayback 
{
	MockedAccelerometerDelegate *delegate = [[MockedAccelerometerDelegate alloc] init];
	NSString *file = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"txt"];
	[accelerometer setDelegate: delegate];
	[accelerometer playFile: file];
	
	STAssertEquals(10, delegate.accelerationsCount, @"all accelerations should be send to delegate"); 
	
	[delegate release];
}	




@end
