//
//  HoccerData.m
//  Hoccer
//
//  Created by Robert Palmer on 24.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//


#import "HoccerData.h"
#import "Preview.h"

@implementation HoccerData
@synthesize data;

- (id) initWithData: (NSData *)theData filename: (NSString *)filename {
	self = [super init];
	if (self != nil) {
		self.data = theData;	
		
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
		NSString *documentsDirectoryUrl = [paths objectAtIndex:0];
		
		filepath = [[documentsDirectoryUrl stringByAppendingPathComponent: filename] retain];
		[data writeToURL:[NSURL fileURLWithPath:filepath] atomically: NO];
	}
	
	return self;
}

- (NSData *)data {
	if (data == nil && filepath != nil) {
		data = [NSData dataWithContentsOfFile:filepath];
	}

	return data;
}

- (void) dealloc {
	NSError *error = nil;
	if (filepath != nil) {
		[[NSFileManager defaultManager] removeItemAtPath:filepath error:&error]; 
	}
	
	[data release];
	[filepath release];
		
	[super dealloc];
}

@end
