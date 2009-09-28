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
	
	if ([featureHistory hasValueAt:-9.81 withVariance:2 onAxis:kYAxis]) {
		NSLog(@"over 9.81");

		if ([featureHistory wasLowerThan:2 onAxis:kYAxis inLast:0.4]) {
			NSString *featurePattern = [featureHistory featurePatternOnAxis:kYAxis inTimeInterval:0.4];
			NSLog(featurePattern);
			
			if ([featurePattern startsWith: @"<down>"] || [featurePattern startsWith:@"<fastdown>"]) {
				if ([featurePattern endsWith: @"flat"] || [featurePattern endsWith: @"<up>"]) {
				
					return YES;
				}
			}
		}
	}
		
		
	return NO;
}

@end
