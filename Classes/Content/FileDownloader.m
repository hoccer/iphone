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

- (void) startTransfer {
	self.state = TransferableStateTransfering;
	
	fileCache = [[HCFileCache alloc] initWithApiKey:API_KEY secret:SECRET];
	fileCache.delegate = self;
	[fileCache load: url];		
}

#pragma mark -
#pragma mark FileCache Delegate Methods
- (void)fileCache: (HCFileCache *)fileCache didReceiveResponse: (NSHTTPURLResponse *)response withDownloadedData: (NSData *)data forURI: (NSString *)uri {
	NSString *directory = [[NSFileManager defaultManager] contentDirectory];
	NSString *tmpFilename = [response suggestedFilename];
	self.filename = [[NSFileManager defaultManager] uniqueFilenameForFilename: tmpFilename 
																  inDirectory: directory];
	
	NSString *filepath = [directory stringByAppendingPathComponent: self.filename];
 	[data writeToFile: filepath atomically:YES];

	self.state = TransferableStateTransferred;
}

@end
