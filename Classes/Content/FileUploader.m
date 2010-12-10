//
//  FileUploader.m
//  Hoccer
//
//  Created by Robert Palmer on 10.12.10.
//  Copyright 2010 Hoccer GmbH. All rights reserved.
//

#import "FileUploader.h"


@implementation FileUploader

- (id)initWithFilename: (NSString *)aFilename {
	self = [super init];
	if (self != nil) {
		self.state = TransferableStateReady; 
		filename = [aFilename retain];
	}
	
	return self;
}

- (void)startTransfer {
	if (fileCache == nil) {
		fileCache = [[HCFileCache alloc] initWithApiKey:API_KEY secret:SECRET];
		fileCache.delegate = self;		
	}

	NSData *data = [NSData dataWithContentsOfFile:self.filename];
	[fileCache cacheData: data withFilename:self.filename forTimeInterval:180];		
	self.state = TransferableStateTransfering;
}

#pragma mark -
#pragma mark FileCache Delegate Methods
- (void)fileCache:(HCFileCache *)fileCache didUploadFileToURI:(NSString *)path {	
	self.state = TransferableStateTransferred;
	self.url = [path retain];
}

@end
