//
//  FeatureHistoryTests.m
//  Hoccer
//
//  Created by Robert Palmer on 22.09.09.
//  Copyright 2009 Hoccer GmbH. All rights reserved.
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

- (void)testFeaturePatternCreator
{
	FeatureHistory *history = [[FeatureHistory alloc] init];
	
	[history addAcceleration: [UIAcceleration accelerationWithX: 0 y:   0 z:0 timestamp:   0]];
	[history addAcceleration: [UIAcceleration accelerationWithX: 0 y: 0.5 z:0 timestamp: 0.01]];
	[history addAcceleration: [UIAcceleration accelerationWithX: 0 y:   0 z:0 timestamp: 0.03]];
	[history addAcceleration: [UIAcceleration accelerationWithX: 0 y:-1.0 z:0 timestamp: 0.2]];

	NSString *pattern = [history featurePatternOnAxis: kYAxis inTimeInterval:200.0];
	
	STAssertEquals((int)[history.yLineFeatures count], 3, @"should be cool"); 
	STAssertEqualObjects(@"<fastup><fastdown><down>", pattern, @"pattern should match");
	
	[history addAcceleration: [UIAcceleration accelerationWithX: 0 y:0.4 z:0 timestamp: 0.35]];

	STAssertEqualObjects(@"<down><up>", [history featurePatternOnAxis: kYAxis inTimeInterval:200], @"pattern should match");
}

- (void)testIsValueAt
{
	FeatureHistory *history = [[FeatureHistory alloc] init];
	
	[history addAcceleration: [UIAcceleration accelerationWithX: 0 y:0 z:0 timestamp:  1]];
	[history addAcceleration: [UIAcceleration accelerationWithX: 0 y:0 z:0 timestamp:  2]];
	[history addAcceleration: [UIAcceleration accelerationWithX: 0 y:1.0 z:0 timestamp:  3]];
	
	STAssertTrue([history hasValueAt:10.0 withVariance:2 onAxis:kYAxis], @"should be around 10");
	STAssertFalse([history hasValueAt:10.0 withVariance:2 onAxis:kZAxis], @"should not be around 10");
}

- (void)testWasLowerThan
{
	FeatureHistory *history = [[FeatureHistory alloc] init];
	
	[history addAcceleration: [UIAcceleration accelerationWithX: 0 y:    0 z:0 timestamp:  10]];
	[history addAcceleration: [UIAcceleration accelerationWithX: 0 y: -0.3 z:0 timestamp:  20]];
	[history addAcceleration: [UIAcceleration accelerationWithX: 0 y:  3 z:0 timestamp:  30]];
	
	STAssertTrue([history wasLowerThan: -0.2 onAxis: kYAxis inLast: 30], @"should be lower than -1.5");
	
	[history addAcceleration: [UIAcceleration accelerationWithX: 0 y:  0 z:0 timestamp:  60]];
	[history addAcceleration: [UIAcceleration accelerationWithX: 0 y:  0 z:0 timestamp:  70]];
	[history addAcceleration: [UIAcceleration accelerationWithX: 0 y:  0 z:0 timestamp:  80]];
	
	STAssertFalse([history wasLowerThan: -0.2 onAxis: kYAxis inLast: 20], @"should be lower than -1.5");
}


@end
