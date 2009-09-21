//
//  LineFeatureTests.m
//  Hoccer
//
//  Created by Robert Palmer on 21.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "LineFeatureTests.h"


@implementation LineFeatureTests

- (void)testAddingPoints 
{
	LineFeature line = [[LineFeature alloc] initWithPoint: CGMakePoint(0, 0)]:
	STAssertEquals(0, line.slope, @"slope");
	STAssertEquals(0, line.length, @"length");
	
	
	
	// LineFeature line = new LineFeature(new Vec2D(0, 0));
	
	// assertEquals("slope", 0f, line.getSlope());
	// assertEquals("length", 0f, line.getLength());
	
//	assertTrue(line.add(new Vec2D(20, -0.5f)));
//	assertEquals("slope", -0.025f, line.getSlope());
//	assertEquals("length", 20f, line.getLength());
//	assertTrue(line.add(new Vec2D(40, 0.5f)));
//	assertTrue(line.add(new Vec2D(60, 0f)));
//	
//	assertEquals("slope", 0f, line.getSlope());
//	assertEquals("length", 60f, line.getLength());
}


@end
