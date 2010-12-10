//
//  FileDownloader.m
//  Hoccer
//
//  Created by Robert Palmer on 09.12.10.
//  Copyright 2010 Hoccer GmbH. All rights reserved.
//

#import "FileDownloader.h"
#import "NSFileManager+FileHelper.h"


@implementation FileDownloader

- (id)initWithURL: (NSString *)aUrl filename: (NSString *)aFilename {
	self = [super init];
	if (self != nil) {
		url = [aUrl retain];
	}
	
	return self;
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
	NSString *directory = [[NSFileManager defaultManager] contentDirectory];
	NSString *tmpFilename =    [[uri lastPathComponent] stringByAppendingString:@".jpg"];
	self.filename = [[NSFileManager defaultManager] uniqueFilenameForFilename: tmpFilename 
																  inDirectory: directory];
	
	NSString *filepath = [directory stringByAppendingPathComponent: self.filename];
	NSLog(@"writing to %@", filepath);
 	[theData writeToFile: filepath atomically:YES];

	self.state = TransferableStateTransferred;
}

@end
