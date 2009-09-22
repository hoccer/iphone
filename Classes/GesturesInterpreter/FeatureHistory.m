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
- (NSString *)chatDataFor: (NSArray *)lineFeatures;

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

- (UIImage *)chart
{
	float length = [[yLineFeatures lastObject] newestPoint].x;
	NSString *minMax = [NSString stringWithFormat: @"0,%f,30,-30", length];
	
	NSMutableString *url = [NSMutableString string];
	[url appendString: @"http://chart.apis.google.com/chart?"];
	[url appendString: @"chs=900x330&cht=lxy&chdl=x|y|z&chco=FF0000,00FF00,0000FF&chg=0,50,1,0"];
	[url appendFormat: @"&chxt=x,y&chxr=0,0,%f|1,-30,30", length];
	[url appendFormat: @"&chds=%@,%@,%@", minMax, minMax, minMax];
	
	[url appendFormat: @"&chd=t:%@|%@|%@", [self chatDataFor: xLineFeatures], 
										   [self chatDataFor: yLineFeatures], 
										   [self chatDataFor: zLineFeatures]];
	
	
	NSLog(@"image from %@", url);
	NSError *error;
	NSData *imageData = [NSData dataWithContentsOfURL: [NSURL URLWithString: [url stringByAddingPercentEscapesUsingEncoding:  NSUTF8StringEncoding]] 
											  options: NSUncachedRead error: &error];
	
	NSLog(@"received data: %@", imageData);
	NSLog(@"error: %@", error);
	
	return [UIImage imageWithData: imageData];
}

- (NSString *)chatDataFor: (NSArray *)lineFeatures
{
	NSMutableString *xValues = [NSMutableString string];
	NSMutableString *yValues = [NSMutableString string];
	
	for (LineFeature *feature in lineFeatures) {
		CGPoint firstPoint = [feature firstPoint];
		CGPoint lastPoint  = [feature newestPoint];
		
		[xValues appendFormat: @"%d,%d,", (int)firstPoint.x, (int)lastPoint.x];
		[yValues appendFormat: @"%d,%d,", (int)firstPoint.y, (int)lastPoint.y];
	}
	
	[xValues deleteCharactersInRange: NSMakeRange([xValues length]-1, 1)];
	[yValues deleteCharactersInRange: NSMakeRange([yValues length]-1, 1)];
	
	return [NSString stringWithFormat:@"%@|%@", xValues, yValues]; 
}








@end
