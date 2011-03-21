//
//  FileTransferer.m
//  Hoccer
//
//  Created by Robert Palmer on 10.12.10.
//  Copyright 2010 Hoccer GmbH. All rights reserved.
//

#import "FileTransferer.h"
#import "NSFileManager+FileHelper.h"

@implementation FileTransferer

@synthesize progress;
@synthesize error;
@synthesize state;

@synthesize filename;
@synthesize url;

- (void) fileCache:(HCFileCache *)fileCache didUpdateProgress:(NSNumber *)theProgress forURI:(NSString *)uri {
	self.progress = theProgress;
}

- (void) fileCache:(HCFileCache *)fileCache didFailWithError:(NSError *)theError forURI:(NSString *)uri {
	self.error = theError;
}

- (void) cancelTransfer {
	[fileCache cancelTransferWithURI:idString];
}

- (void) startTransfer {
	[self doesNotRecognizeSelector:_cmd];
}

- (NSInteger)size {
    NSString *directory = [[NSFileManager defaultManager] contentDirectory];
    NSString *aFilename = [directory stringByAppendingPathComponent:self.filename];
    
    NSDictionary *attr = [[NSFileManager defaultManager] attributesOfItemAtPath:aFilename error:nil];
    return [[attr objectForKey:NSFileSize] intValue];
}

- (void)dealloc {
	[fileCache release];
	[idString release];
	
	[url release];
	[filename release];
	
	[progress release];
	[error release];
	
	[super dealloc];
}


@end
