//
//  FileDownloader.m
//  Hoccer
//
//  Created by Robert Palmer on 09.12.10.
//  Copyright 2010 Hoccer GmbH. All rights reserved.
//

#import "FileDownloader.h"


@implementation FileDownloader

@synthesize progress;
@synthesize error;
@synthesize state;

@synthesize filename;
@synthesize url;

- (id)initWithURL: (NSString *)aUrl {
	self = [super init];
	if (self != nil) {
		url = [aUrl retain];		
	}
	return self;
}

- (void)dealloc {
	[fileCache release];
	
	[url release];
	[filename release];
	
	[progress release];
	[error release];
	
	[super dealloc];
}


- (void) cancelTransfer {
}

- (void) startTransfer {
	self.state = TransferableStateTransfering;
	
	fileCache = [[HCFileCache alloc] initWithApiKey:API_KEY secret:SECRET];
	fileCache.delegate = self;
	[fileCache load: url];		
}

#pragma mark -
#pragma mark FileCache Delegate Methods
- (void) fileCache:(HCFileCache *)fileCache didDownloadData:(NSData *)theData forURI:(NSString *)uri {
	self.state = TransferableStateTransferred;
	
	
	
// [theData writeToFile: atomically:YES];
// 	self.data = [theData retain];
//	[self saveDataToDocumentDirectory];
}

- (void) fileCache:(HCFileCache *)fileCache didUpdateProgress:(NSNumber *)theProgress forURI:(NSString *)uri {
	self.progress = theProgress;
}

- (void) fileCache:(HCFileCache *)fileCache didFailWithError:(NSError *)theError forURI:(NSString *)uri {
	NSLog(@"error: %@", error);
	self.error = theError;
}



@end
