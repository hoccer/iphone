//
//  FeatureHistory.m
//  Hoccer
//
//  Created by Robert Palmer on 22.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "FeatureHistory.h"
#import "LineFeature.h"

@interface FeatureHistory (Private)

- (void) addPoint: (CGPoint) newPoint toLine: (NSMutableArray *)lineFeatures;

@end

@implementation FeatureHistory

@synthesize  xLineFeatures, yLineFeatures, zLineFeatures;


- (id) init
{
	self = [super init];
	if (self != nil) {
		xLineFeatures =[[NSMutableArray alloc] init]; 
		yLineFeatures =[[NSMutableArray alloc] init]; 
		zLineFeatures =[[NSMutableArray alloc] init]; 
		
	}
	return self;
}

- (void)dealloc
{
	[xLineFeatures release];
	[yLineFeatures release];
	[zLineFeatures release];

	[super dealloc];
}

- (void)addAcceleration : (UIAcceleration *)acceleration 
{
	[self addPoint: CGPointMake(acceleration.timestamp, acceleration.x) 
			toLine: xLineFeatures]; 
	
	[self addPoint: CGPointMake(acceleration.timestamp, acceleration.y) 
			toLine: yLineFeatures]; 
	
	[self addPoint: CGPointMake(acceleration.timestamp, acceleration.z) 
			toLine: zLineFeatures]; 
}

- (void) addPoint: (CGPoint)newPoint toLine: (NSMutableArray *)lineFeatures 
{
	if ([lineFeatures count] == 0) {
		[lineFeatures addObject: [LineFeature lineFeatureWithPoint: newPoint]]; 
	} else if (![[lineFeatures lastObject] addPoint: newPoint]) {
		CGPoint lastPoint = [[lineFeatures lastObject] newestPoint];
		[lineFeatures addObject:[LineFeature lineFeatureWithPoint: lastPoint andPoint: newPoint]]; 
	} 
}

@end
