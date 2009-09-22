//
//  AccelerationRecorder.m
//  Hoccer
//
//  Created by Robert Palmer on 14.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "AccelerationRecorder.h"
#import "FeatureHistory.h"

@interface AccelerationRecorder (private)
- (NSString *)directoryForAccelerationData;
- (NSString *)filenameFromCurrentTime;
- (NSString *)formatAccelerationData: (UIAcceleration *)accelertion;
@end

@implementation AccelerationRecorder

@synthesize filename;
@synthesize featureHistory;

- (void)startRecording
{
	[UIAccelerometer sharedAccelerometer].delegate = self;
	[UIAccelerometer sharedAccelerometer].updateInterval = 0.02;
	
	self.featureHistory = [[FeatureHistory alloc] init]; 
	
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
	self.featureHistory = nil;
	
	[file closeFile];
	[file release];

	[super dealloc];
}

#pragma mark -
#pragma mark UIAccelerationDelegate methods
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration 
{
	NSLog(@"%f,%f,%f,%f\n", acceleration.timestamp, acceleration.x, 
		  acceleration.y, acceleration.z);

	[file writeData: [[self formatAccelerationData:acceleration] dataUsingEncoding: NSUTF8StringEncoding]];
	
	[featureHistory addAcceleration: acceleration];
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

- (NSString *)formatAccelerationData: (UIAcceleration *)acceleration
{
	return [NSString stringWithFormat:@"%f,%f,%f,%f\n", acceleration.timestamp, acceleration.x, 
													  acceleration.y, acceleration.z];
}

	
@end
