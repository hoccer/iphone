//
//  Y60AsyncTestHelper.m
//  Hoccer
//
//  Created by Robert Palmer on 20.04.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "Y60AsyncTestHelper.h"


@implementation Y60AsyncTestHelper

+ (BOOL)waitForTarget: (id)target selector: (SEL)selector toBecome: (NSInteger)value atLeast: (NSTimeInterval)seconds {
	NSDate *startTime = [NSDate date];
	
	while ([[NSDate date] timeIntervalSinceDate:startTime] < seconds) {
		if ((NSInteger)[target performSelector:selector] == value) {
			return YES;
		}
		
		[NSThread sleepForTimeInterval:0.2];
	}
	
	return NO;
}

@end
