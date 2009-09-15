//
//  AccelerationRecorder.m
//  Hoccer
//
//  Created by Robert Palmer on 14.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "AccelerationRecorder.h"

@interface AccelerationRecorder (private)
- (NSString *)directoryForAccelerationData;
- (NSString *)filenameFromCurrentTime;
@end


@implementation AccelerationRecorder

@synthesize filename;

- (void)startRecording
{
	[UIAccelerometer sharedAccelerometer].delegate = self;
	[UIAccelerometer sharedAccelerometer].updateInterval = 0.01;
	
	NSString *gesturesDirectory = [self directoryForAccelerationData];
	self.filename = [self filenameFromCurrentTime];
	
	self.filename = [gesturesDirectory stringByAppendingPathComponent: self.filename];
	NSLog(@"recording to: %@", self.filename);
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:self.filename]) {
		[[NSFileManager defaultManager]createFileAtPath:self.filename contents:nil attributes:nil];
	}
	
	file = [NSFileHandle fileHandleForWritingAtPath: self.filename];
	[file retain];
}
	
- (void)stopRecording
{
	[UIAccelerometer sharedAccelerometer].delegate = nil;
	
	[file closeFile];
	[file release];
	file = nil;
}


- (void)dealloc 
{
	[super dealloc];
	
	[file closeFile];
	[file release];
}

#pragma mark -
#pragma mark UIAccelerationDelegate methods
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration 
{
	[file writeData: [[acceleration description] dataUsingEncoding: NSUTF8StringEncoding]];
}


#pragma mark -
#pragma mark private methods
	
- (NSString *)directoryForAccelerationData
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	NSString *gesturesDirectory = [documentsDirectory stringByAppendingPathComponent:@"gestures"];
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:gesturesDirectory]) {
		[[NSFileManager defaultManager] createDirectoryAtPath:gesturesDirectory attributes:nil];
	}
	
	return gesturesDirectory;
}

- (NSString *)filenameFromCurrentTime
{
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyy-MM-dd_HH-mm"];
	
	NSString *date = [formatter stringFromDate: [NSDate date]];
	
	[formatter release];
	
	return [date stringByAppendingPathExtension:@"txt"];
}

	

	
@end
