//
//  FileTransferer.m
//  Hoccer
//
//  Created by Robert Palmer on 10.12.10.
//  Copyright 2010 Hoccer GmbH. All rights reserved.
//

#import "FileTransferer.h"


@implementation FileTransferer

@synthesize progress;
@synthesize error;
@synthesize state;

@synthesize filename;
@synthesize url;


- (void)dealloc {
	[fileCache release];
	
	[url release];
	[filename release];
	
	[progress release];
	[error release];
	
	[super dealloc];
}

- (void) fileCache:(HCFileCache *)fileCache didUpdateProgress:(NSNumber *)theProgress forURI:(NSString *)uri {
	self.progress = theProgress;
}

- (void) fileCache:(HCFileCache *)fileCache didFailWithError:(NSError *)theError forURI:(NSString *)uri {
	NSLog(@"error: %@", error);
	self.error = theError;
}

- (void) cancelTransfer {
	
}

- (void) startTransfer {
	[self doesNotRecognizeSelector:_cmd];
}



@end
