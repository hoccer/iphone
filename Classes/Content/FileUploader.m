//
//  FileUploader.m
//  Hoccer
//
//  Created by Robert Palmer on 10.12.10.
//  Copyright 2010 Hoccer GmbH. All rights reserved.
//

#import "FileUploader.h"
#import "NSFileManager+FileHelper.h"


@implementation FileUploader
@synthesize cryptor;

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
		fileCache = [[HCFileCache alloc] initWithApiKey:API_KEY secret:SECRET sandboxed: USES_SANDBOX];
		fileCache.delegate = self;		
	}

	NSString *directory = [[NSFileManager defaultManager] contentDirectory];
	NSString *filepath = [directory stringByAppendingPathComponent: self.filename];
	
	NSData *data = [NSData dataWithContentsOfFile:filepath];
    NSData *crypted = [cryptor encrypt:data];
	self.url = [fileCache cacheData: crypted withFilename:self.filename forTimeInterval:180*60];
	self.state = TransferableStateTransfering;
	
	idString = [self.url copy];
}

#pragma mark -
#pragma mark FileCache Delegate Methods
- (void)fileCache:(HCFileCache *)fileCache didUploadFileToURI:(NSString *)path {	
	self.state = TransferableStateTransferred;
}

@end