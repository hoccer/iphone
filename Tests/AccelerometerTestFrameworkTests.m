//
//  AccelerometerTest.m
//  Hoccer
//
//  Created by Robert Palmer on 14.09.09.
//  Copyright 2009 Hoccer GmbH. All rights reserved.
//

#import "AccelerometerTestFrameworkTests.h"
#import "MockedAccelerometerDelegate.h"
#import "UIAccelerometer+TestPlayback.h"

@implementation AccelerometerTestFrameworkTests

- (void) setUp 
{
	accelerometer = [UIAccelerometer sharedAccelerometer];
	STAssertNotNil(accelerometer, @"shared accelerometer should be available");
}

- (void)testAccelerometerPlayback 
{
	MockedAccelerometerDelegate *delegate = [[MockedAccelerometerDelegate alloc] init];

	NSString *file = [[NSBundle bundleForClass:[self class]] pathForResource:@"2_values" ofType:@"txt"];
	STAssertNotNil(file, @"filepath should not be null");
	
	[accelerometer setDelegate: delegate];
	[accelerometer playFile: file];
	
	GHAssertEquals(2, delegate.accelerationsCount, @"all accelerations should be send to delegate"); 
	
	NSArray* accelerationStrings = [[NSString stringWithContentsOfFile: file] componentsSeparatedByString:@"\n"];
	NSArray* firstAcceleration = [[accelerationStrings objectAtIndex:0] componentsSeparatedByString:@","];
	
	
	// assert the right order of received items
	STAssertEquals([[firstAcceleration objectAtIndex:0] doubleValue],
				   [[delegate.receivedAccelarations objectAtIndex:0] timestamp], @"");
	
	NSArray* secondAcceleration = [[accelerationStrings objectAtIndex:1] componentsSeparatedByString:@","];
	
	STAssertEquals([[secondAcceleration objectAtIndex:0] doubleValue],
				   [[delegate.receivedAccelarations objectAtIndex:1] timestamp], 
				   @"");
	
	[delegate release];
}

- (void)testSplittingLine
{
	NSArray *result = [accelerometer splitLine: @"1248352045851,0.08172209,1.7570249,9.39804"];
	STAssertNotNil(result, @"splitted line should not be null");
	
	STAssertEquals(4, (NSInteger)[result count], @"line should be splited at ','");
}






@end
