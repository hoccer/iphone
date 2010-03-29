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

- (id) initWithData: (NSData *)theData filename: (NSString *)filename {
	self = [super init];
	if (self != nil) {
		data = [theData retain];	
		
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
		NSString *documentsDirectoryUrl = [paths objectAtIndex:0];
		
		filepath = [documentsDirectoryUrl stringByAppendingPathComponent: filename];
		[data writeToURL:[NSURL fileURLWithPath:filepath] atomically: NO];
	}
	
	return self;
}

- (void) dealloc {
	[data release];
	[filepath release];
		
	[super dealloc];
}

@end
