//
//  LineFeature.m
//  Hoccer
//
//  Created by Robert Palmer on 21.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "LineFeature.h"


@interface LineFeature (Private)

- (float)calculateSlopeBetween: (CGPoint) firstPoint and: (CGPoint) secondPoint;
- (float)expectedYValueForX: (float)x;
- (void)compress;

@end


@implementation LineFeature


- (id)initWithPoint: (CGPoint)point
{
	self = [super init];
	if (self != nil) {
		points = [[NSMutableArray alloc] init];
		[self addPoint: point];
	}
	return self;
}


- (BOOL)addPoint: (CGPoint)point 
{
	if (![self isValid: point])
		return NO;
	
	[self compress];
	[points addObject:[NSValue valueWithCGPoint: point]];
	return YES;
}	

- (float)slope
{
	if ([points count] < 2)
		return 0;
	
	float slopeSum = 0;
	for (int i = 0; i < [points count] - 1; i++) {
		CGPoint pointA = [[points objectAtIndex:   i] CGPointValue];
		CGPoint pointB = [[points objectAtIndex: i+1] CGPointValue];
		
		slopeSum += [self calculateSlopeBetween:pointA and: pointB];
	}
	
	
	return slopeSum / ([points count] - 1);
}

- (float)length
{
	if ([points count] < 2)
		return 0;
	
	CGPoint first = [[points objectAtIndex: 0] CGPointValue];
	CGPoint last = [[points lastObject] CGPointValue];
	
	return last.x - first.x;
}


#pragma mark -
#pragma mark Private Helper Methods

- (float)calculateSlopeBetween: (CGPoint) firstPoint and: (CGPoint) secondPoint 
{
	return (secondPoint.y - firstPoint.y) / (secondPoint.x - firstPoint.x);
}

- (BOOL)isValid: (CGPoint) point {
	if ([points count] < 2)
		return YES;
	
	return (fabsf([self expectedYValueForX: point.x] - point.y) < 2);
}

- (float)expectedYValueForX: (float)x 
{
	return self.slope * x + self.yIntersection;
}

- (float)yIntersection
{
	CGPoint center = [self center];
	
	return center.y - self.slope * center.x; 
}


- (CGPoint)center
{
	float avarageY = 0;
	for (int i = 0; i < [points count]; i++) {
		avarageY += [[points  objectAtIndex:i] CGPointValue].y;
	}
	
	avarageY /= [points count];
	CGPoint first = [[points objectAtIndex:0] CGPointValue];
	
	return CGPointMake(first.x + self.length, avarageY);
}

- (void)compress
{
	if ([points count] < 20)
		return;
	
	NSMutableArray *compressedPoints = [[NSMutableArray alloc] init];
	
	for (int i = 0; i < [points count]; i++) {
		if (i % 3 == 0) {
			[compressedPoints addObject:[points objectAtIndex:i]];
		}
	}
	
	[points release];
	points = compressedPoints;
}

@end
