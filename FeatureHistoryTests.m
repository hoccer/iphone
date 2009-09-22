//
//  FeatureHistoryTests.m
//  Hoccer
//
//  Created by Robert Palmer on 22.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "FeatureHistoryTests.h"
#import "FeatureHistory.h"

#import "UIAcceleration+TestSetters.h"

#define kXAxis 0

@implementation FeatureHistoryTests

- (void)testDetectingLineFeature
{
	FeatureHistory *history = [[FeatureHistory alloc] init];
	
	[history addAcceleration: [UIAcceleration accelerationWithX: 0 y:0 z:0 timestamp:  1]];
	[history addAcceleration: [UIAcceleration accelerationWithX: 0 y:0 z:0 timestamp:  2]];
	[history addAcceleration: [UIAcceleration accelerationWithX: 0 y:0 z:0 timestamp:  3]];
	[history addAcceleration: [UIAcceleration accelerationWithX: 0 y:0 z:0 timestamp:  4]];
	[history addAcceleration: [UIAcceleration accelerationWithX: 0 y:0 z:0 timestamp:  5]];
	[history addAcceleration: [UIAcceleration accelerationWithX: 5 y:0 z:0 timestamp:  6]];
	[history addAcceleration: [UIAcceleration accelerationWithX:10 y:0 z:0 timestamp:  7]];
	[history addAcceleration: [UIAcceleration accelerationWithX:15 y:0 z:0 timestamp:  8]];
	[history addAcceleration: [UIAcceleration accelerationWithX:10 y:0 z:0 timestamp:  9]];
	[history addAcceleration: [UIAcceleration accelerationWithX: 5 y:0 z:0 timestamp: 10]];
	[history addAcceleration: [UIAcceleration accelerationWithX: 0 y:0 z:0 timestamp: 11]];

	NSInteger count = [history.xLineFeatures count];
	STAssertEquals(3, count, @"line should have 3 features");
	
	[history release];
}	

- (void) testFeaturePatternCreator
{
	FeatureHistory *history = [[FeatureHistory alloc] init];
	
	[history addAcceleration: [UIAcceleration accelerationWithX: 0 y:   0 z:0 timestamp:   1]];
	[history addAcceleration: [UIAcceleration accelerationWithX: 0 y: 0.5 z:0 timestamp:  10]];
	[history addAcceleration: [UIAcceleration accelerationWithX: 0 y:   0 z:0 timestamp:  30]];
	[history addAcceleration: [UIAcceleration accelerationWithX: 0 y:-1.0 z:0 timestamp: 200]];


	NSString *pattern = [history featurePatternOnAxis: kYAxis inTimeInterval:200];
	
	STAssertEquals((int)[history.yLineFeatures count], 3, @"should be cool"); 
	STAssertEqualObjects(@"<fastup><fastdown><down>", pattern, @"pattern should match");
	
//	history.add(new Vec3D(0, -4, 0), 300);
//	pattern = history.getFeaturePattern(200, SensorManager.DATA_Y);
//	history.logHistory();
//	Logger.v("featurePatternTest:", "pattern " + pattern);
//	assertEquals("should get only two features", "<down><up>", pattern.toString());
}

@end
