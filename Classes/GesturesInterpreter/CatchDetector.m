//
//  CatchDetector.m
//  Hoccer
//
//  Created by Robert Palmer on 23.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "CatchDetector.h"
#import "NSString+Regexp.h"


@implementation CatchDetector

- (BOOL)detect: (FeatureHistory *)featureHistory
{
	if ([featureHistory hasValueAt:9.81 withVariance:2 onAxis:kYAxis]) {
		
		if ([featureHistory wasLowerThan:2 onAxis:kYAxis inLast:1]) {
			NSString *featurePattern = [featureHistory featurePatternOnAxis:kYAxis inTimeInterval:1];
			NSLog(featurePattern);
			
			if ([featurePattern startsWith: @"<up>"] || [featurePattern startsWith:@"fastup"]) {
				if ([featurePattern endsWith: @"flat"] || [featurePattern endsWith: @"down"]) {
				
					return YES;
				}
			}
		}
	}
		
		
	return NO;
}

@end
