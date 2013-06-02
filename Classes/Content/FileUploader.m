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
@synthesize uploadURL;

- (id)initWithFilename: (NSString *)aFilename {
	self = [super init];
	if (self != nil) {
		self.state = TransferableStateReady; 
		self.filename = [aFilename retain];
        if (fileCache == nil) {
            fileCache = [[HCFileCache alloc] initWithApiKey:API_KEY secret:SECRET sandboxed: USES_SANDBOX];
            fileCache.delegate = self;
        }
        self.uploadURL = [fileCache getNewTransferURL];
	}
	
	return self;
}

- (void)startTransfer {
    if (USES_DEBUG_MESSAGES) { NSLog(@"FileUploader: startTransfer %@", self.filename);}

	NSString *directory = [[NSFileManager defaultManager] contentDirectory];
	NSString *filepath = [directory stringByAppendingPathComponent: self.filename];
	
	NSData *data = [NSData dataWithContentsOfFile:filepath];
    NSData *crypted = [cryptor encrypt:data];
    
    NSURL * myFullURL = [NSURL URLWithString:self.uploadURL];
    NSString * myRelativeURL = [myFullURL lastPathComponent];
    
	self.url = [fileCache cacheData: crypted withFilename:self.filename forTimeInterval:180*60 withSize: [self transfersize] forURLName:myRelativeURL];
	self.state = TransferableStateTransferring;
	
	idString = [self.url copy];
}


#pragma mark -
#pragma mark FileCache Delegate Methods
- (void)fileCache:(HCFileCache *)fileCache didUploadFileToURI:(NSString *)path {	
    if (USES_DEBUG_MESSAGES) { NSLog(@"FileUploader: didUploadFileToURI %@", path);}
	self.state = TransferableStateTransferred;
}

- (void) fileCache:(HCFileCache *)theFileCache didFailWithError:(NSError *)theError forURI:(NSString *)uri {
	
    NSLog(@"FileUploader: didFailWithError code = %@", theError);
	if (retryCount <= 4) {
        NSLog(@"FileUploader: didFailWithError retrying, retryCount = %i", retryCount);
		retryCount += 1;
		[NSTimer scheduledTimerWithTimeInterval:2*retryCount target:self selector:@selector(startTransfer) userInfo:nil repeats:NO];
	} else {
        [super fileCache:theFileCache didFailWithError:theError forURI:uri];
    }
}

@end