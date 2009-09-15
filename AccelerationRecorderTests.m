//
//  AccelerationRecorderTests.m
//  Hoccer
//
//  Created by Robert Palmer on 14.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "AccelerationRecorderTests.h"

#import "UIAccelerometer+TestPlayback.h"
#import "AccelerationRecorder.h"
#import "HoccerImage.h"

@implementation AccelerationRecorderTests

- (void)testAccelerationRecorder 
{
	
	AccelerationRecorder *recorder = [[AccelerationRecorder alloc] init];
	[recorder startRecording];
	
	NSString *file = [[NSBundle bundleForClass:[self class]] pathForResource:@"2_values" ofType:@"txt"];
	STAssertNotNil(file, @"file should be opened");
	
	[[UIAccelerometer sharedAccelerometer] playFile: file];
	
	[recorder stopRecording];
	NSString *recordedFile = recorder.filename;
	STAssertNotNil(recordedFile, @"recorded file should have a name");
	
	NSArray *playbackData = [[NSString stringWithContentsOfFile:file] 
									componentsSeparatedByString:@"\n"];

	NSArray *recordedData = [[NSString stringWithContentsOfFile:recordedFile] 
									componentsSeparatedByString:@"\n"];
	
	STAssertEquals([playbackData count], [recordedData count], @"playback and recorded file should have same amount of values");
	
	[recorder release];
}


@end
