//
//  ThrowDetector.m
//  Hoccer
//
//  Created by Robert Palmer on 28.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "ThrowDetector.h"
#import "FeatureHistory.h"
#import "NSString+Regexp.h"

@implementation ThrowDetector

- (BOOL)detect: (FeatureHistory *)featureHistory
{
	NSString  *yFeaturePattern = [featureHistory featurePatternOnAxis:kYAxis inTimeInterval: 500];
	
	if ([yFeaturePattern endsWith:@"down>"]) {
		
		if  ([featureHistory wasLowerThan: 0 onAxis: kYAxis inLast: 10]) {
			
			if ([featureHistory wasHigherThan: 19 onAxis: kYAxis inLast: 500]) {
				return YES;
			}
			
		}
		
	}
	
	return NO;
}

@end
