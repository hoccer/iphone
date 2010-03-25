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
		
		filePath = [documentsDirectoryUrl stringByAppendingPathComponent: filename];
		[data writeToURL:[NSURL fileURLWithPath:filePath] atomically: NO];
	}
	
	return self;
}

- (void) dealloc {
	[data release];
	[filePath release];
		
	[super dealloc];
}

- (void)save {}

- (void)dismiss {}

- (UIView *)view {
	return nil;
}



- (Preview *)thumbnailView {
	return nil;
}

- (NSString *)filename {
	return filePath;
}
- (NSString *)mimeType {
	return @"audio/mpeg";
}

- (NSData *)data {
	return data;
}


- (BOOL)isDataReady {
	return YES;
}

- (NSString *)saveButtonDescription {
	return @"Save";
}

- (void)contentWillBeDismissed {}


- (BOOL)needsWaiting {
	return NO;
}

- (void)whenReadyCallTarget: (id)aTarget selector: (SEL)aSelector {

}



@end
