//
//  UIAccelerometer+TestPlayback.m
//  Hoccer
//
//  Created by Robert Palmer on 14.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "UIAccelerometer+TestPlayback.h"


@implementation UIAccelerometer (TestPlayback)

- (void)playFile: (NSString *)file 
{
	NSArray *recordedData = [[NSString stringWithContentsOfFile: file] componentsSeparatedByString:@"\n"];
	
	for (int i = 0; i < [recordedData count]; i++) {
		[self.delegate accelerometer:self didAccelerate:nil];
	}
}

@end
