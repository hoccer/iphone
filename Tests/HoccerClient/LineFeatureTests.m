//
//  LineFeatureTests.m
//  Hoccer
//
//  Created by Robert Palmer on 21.09.09.
//  Copyright 2009 Hoccer GmbH. All rights reserved.
//

#import "LineFeatureTests.h"
#import "LineFeature.h"

@implementation LineFeatureTests

- (void)testAddingPoints 
{
	LineFeature *line = [[LineFeature alloc] initWithPoint: CGPointMake(0, 0)];
	STAssertEquals(0.0f, line.slope, @"slope");
	STAssertEquals(0.0f, line.length, @"length");
	
	STAssertEquals(0.0f, line.center.x, @"center x");
	
	STAssertTrue([line addPoint: CGPointMake(20, -0.5f)], @"adding points should be possible");
	
	STAssertEquals(-0.025f, line.slope, @"slope");
	STAssertEquals(20.0f, line.length, @"length");
	
	STAssertTrue([line addPoint: CGPointMake(40, 0.5f)], @"adding points should be possible");
	STAssertTrue([line addPoint: CGPointMake(60, 0.0f)], @"adding points should be possible");

	STAssertEquals(0.0f, line.slope, @"slope");
	STAssertEquals(60.0f, line.length, @"length");
	
	[line release];
}

- (void)testAddingPoints2 
{
	LineFeature *line =  [LineFeature lineFeatureWithPoint:CGPointMake(1, 0)];
	STAssertTrue([line addPoint: CGPointMake(2, 0)], @"adding points should be possible");
	STAssertTrue([line addPoint: CGPointMake(3, 0)], @"adding points should be possible");
	STAssertTrue([line addPoint: CGPointMake(4, 0)], @"adding points should be possible");
	STAssertFalse([line addPoint: CGPointMake(5, 5)], @"adding points should be possible");
}

- (void)testAddingPoints3 
{
	LineFeature *line =  [LineFeature lineFeatureWithPoint:CGPointMake(0, 0)];
	STAssertTrue([line addPoint: CGPointMake(20, 5)], @"adding points should be possible");
	STAssertEquals(line.slope, 5/20.0f, @"slope");
	
	STAssertEquals(line.center.x, 10.0f, @"center x");
	STAssertEquals(line.yIntersection, 0.0f, @"y intersection");
	
	STAssertTrue([line addPoint: CGPointMake(40, 10)], @"adding points should be possible");
	
	STAssertTrue([line addPoint: CGPointMake(60, 15)], @"adding points should be possible");
	STAssertFalse([line addPoint: CGPointMake(80, 10)], @"adding points should be possible");
}

- (void)testAddingPointsWithRejection 
{
	LineFeature *line = [[LineFeature alloc] initWithPoint: CGPointMake(0, 0)];

	STAssertTrue([line addPoint: CGPointMake(20, 1.0f)], @"adding points should be possible");
	STAssertTrue([line addPoint: CGPointMake(40, 2.0f)], @"adding points should be possible");
	STAssertFalse([line addPoint: CGPointMake(60, -1.0f)], @"adding points should be possible");

	STAssertEquals( 1 / 20.0f, line.slope, @"slope");
	STAssertEquals(40.0f, line.length, @"length");
	
	[line release];
}

- (void)testAddingManyPoints
{
	LineFeature *line = [[LineFeature alloc] initWithPoint: CGPointMake(0, 0)];
	
	for (int i = 1; i < 50; i++) {
		STAssertTrue([line addPoint: CGPointMake(i * 20, 0)], @"should add this point");
		STAssertFalse([line isValid:  CGPointMake((i + 1) * 20, 3)], @"should not add this point");
	}
	
	[line release];
}

- (void)testIsDescending
{
	LineFeature *line = [[LineFeature alloc] initWithPoint: CGPointMake(0, 0)];
	STAssertTrue([line addPoint: CGPointMake(20, -0.5f)], @"adding points should be possible");
	STAssertTrue([line addPoint: CGPointMake(40, -1.0f)], @"adding points should be possible");
	STAssertTrue([line addPoint: CGPointMake(60, -1.5f)], @"adding points should be possible");

	STAssertTrue([line isDescending], @"should be descending");
	STAssertFalse([line isFlat],  @"should not be flat");
	STAssertFalse([line isAscending], @"should be ascending");
	
	STAssertEqualObjects(line.type, @"<down>", @"type should be down");
	
	[line release];
}

- (void)testIsAscending
{
	LineFeature *line = [[LineFeature alloc] initWithPoint: CGPointMake(0, 0)];
	STAssertTrue([line addPoint: CGPointMake(20, 0.5f)], @"adding points should be possible");
	STAssertTrue([line addPoint: CGPointMake(40, 1.0f)], @"adding points should be possible");
	STAssertTrue([line addPoint: CGPointMake(60, 1.5f)], @"adding points should be possible");
	
	STAssertFalse([line isDescending], @"should be descending");
	STAssertFalse([line isFlat],  @"should not be flat");
	STAssertTrue([line isAscending], @"should be ascending");
	
	STAssertEqualObjects(line.type, @"<up>", @"should be up");
	
	[line release];
}

-  (void)testIsFlat
{
	LineFeature *line = [[LineFeature alloc] initWithPoint: CGPointMake(0, 0)];
	STAssertTrue([line addPoint: CGPointMake(20,  0.03f)], @"adding points should be possible");
	STAssertTrue([line addPoint: CGPointMake(40, 0.01f)], @"adding points should be possible");
	STAssertTrue([line addPoint: CGPointMake(60, -0.02f)], @"adding points should be possible");
	
	STAssertFalse([line isDescending], @"should  not be descending");
	STAssertTrue([line isFlat],  @"should be flat");
	STAssertFalse([line isAscending], @"should not be ascending");
	
	STAssertEqualObjects(line.type, @"<flat>", @"should be flat");
	
	[line release];
}


-  (void)testIsFastAscendiong
{
	LineFeature *line = [[LineFeature alloc] initWithPoint: CGPointMake(0, 0)];
	STAssertTrue([line addPoint: CGPointMake(.02, 2.0f)], @"adding points should be possible");
	STAssertTrue([line addPoint: CGPointMake(.04, 4.0f)], @"adding points should be possible");
	STAssertTrue([line addPoint: CGPointMake(.06, 6.0f)], @"adding points should be possible");
	
	STAssertEqualObjects(line.type, @"<fastup>", @"should be fastup");
	
	[line release];
}


-  (void)testIsFastDescending
{
	LineFeature *line = [[LineFeature alloc] initWithPoint: CGPointMake(0, 0)];
	STAssertTrue([line addPoint: CGPointMake(.02, -2.0f)], @"adding points should be possible");
	STAssertTrue([line addPoint: CGPointMake(.04, -4.0f)], @"adding points should be possible");
	STAssertTrue([line addPoint: CGPointMake(.06, -6.0f)], @"adding points should be possible");
	
	STAssertEqualObjects(line.type, @"<fastdown>", @"should be flat");

	[line release];
}

@end
