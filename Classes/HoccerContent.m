//
//  HoccerData.m
//  Hoccer
//
//  Created by Robert Palmer on 24.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//


#import "HoccerContent.h"
#import "Preview.h"

@implementation HoccerContent
@synthesize data;
@synthesize filepath;


- (id) initWithData: (NSData *)theData filename: (NSString *)filename {
	self = [super init];
	if (self != nil) {
			
		[self setData:theData filename: filename];

	}
	
	return self;
}

- (NSData *)data {
	if (data == nil && filepath != nil) {
		data = [NSData dataWithContentsOfFile:filepath];
	}

	return data;
}

- (void) setData:(NSData *) theData filename: (NSString*) aFilename{
	
	self.data = theData;
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
	NSString *documentsDirectoryUrl = [paths objectAtIndex:0];
	
	self.filepath = [documentsDirectoryUrl stringByAppendingPathComponent: aFilename];
	[data writeToFile: filepath atomically: NO];
}

- (void) removeFromDocumentDirectory{
	NSError *error = nil;
	if (filepath != nil) {
		[[NSFileManager defaultManager] removeItemAtPath:filepath error:&error]; 
	}	
}

- (void) dealloc {	
	[data release];
	[filepath release];
		
	[super dealloc];
}

@end
