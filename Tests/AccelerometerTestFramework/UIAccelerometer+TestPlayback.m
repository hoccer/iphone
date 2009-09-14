//
//  UIAccelerometer+TestPlayback.m
//  Hoccer
//
//  Created by Robert Palmer on 14.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "UIAccelerometer+TestPlayback.h"
#import "UIAcceleration+TestSetters.h"

@implementation UIAccelerometer (TestPlayback)

- (void)playFile: (NSString *)file 
{
	NSError *error;
	NSArray *recordedData = [[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:&error] 
									componentsSeparatedByString:@"\n"];
	
	for (NSString *line in recordedData) {
		NSLog(@"line: %@", line);
		NSArray *accelerationComponents = [self splitLine: line];
		
		if ([accelerationComponents count] != 4) {
			return;
		}
		
		UIAcceleration *acceleration = [[[UIAcceleration alloc] init] autorelease];
		acceleration.timestamp = [[accelerationComponents objectAtIndex:0] doubleValue];
		acceleration.x = [[accelerationComponents objectAtIndex:1] doubleValue];
		acceleration.y = [[accelerationComponents objectAtIndex:2] doubleValue];
		acceleration.z = [[accelerationComponents objectAtIndex:3] doubleValue];

		[self.delegate accelerometer:self didAccelerate:acceleration];
	}
}


- (NSArray *)splitLine: (NSString *)line 
{
	return [line componentsSeparatedByString: @","];
}

@end
