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
@synthesize cryptor;

- (id)initWithURL: (NSString *)aUrl filename: (NSString *)aFilename {
	self = [super init];
	if (self != nil) {
		super.url = aUrl;
        self.filename = aFilename;
	}
	
	return self;
}

- (void) startTransfer {
    if (USES_DEBUG_MESSAGES) {  NSLog(@"FileDownloader: startTransfer %@", self.url);}
	self.state = TransferableStateTransferring;
	if (fileCache == nil) {
		fileCache = [[HCFileCache alloc] initWithApiKey:API_KEY secret:SECRET sandboxed: USES_SANDBOX];
		fileCache.delegate = self;
	}
	
	idString = [[fileCache load: self.url] copy];		
}

- (NSInteger)transfersize {
    return self.progress.total;
}

#pragma mark -
#pragma mark FileCache Delegate Methods
- (void)fileCache: (HCFileCache *)fileCache didReceiveResponse: (NSHTTPURLResponse *)response withDownloadedData: (NSData *)data forURI: (NSString *)uri {
    if (USES_DEBUG_MESSAGES) {  NSLog(@"FileDownloader: didReceiveResponse uri = %@", uri);}

    NSString *directory = [[NSFileManager defaultManager] contentDirectory];
	NSString *filepath = [directory stringByAppendingPathComponent: self.filename];
    NSData* decrypted = [self.cryptor decrypt:data];
    
 	[decrypted writeToFile: filepath atomically:YES];

	self.state = TransferableStateTransferred;
}

- (void) fileCache:(HCFileCache *)theFileCache didFailWithError:(NSError *)theError forURI:(NSString *)uri {
	
    NSLog(@"FileDownloader: didFailWithError code = %@", theError);
	if ([theError code] == 404 && retryCount <= 4) {
        NSLog(@"FileDownloader: didFailWithError retrying, retryCount = %i", retryCount);
		retryCount += 1;
		[NSTimer scheduledTimerWithTimeInterval:2*retryCount target:self selector:@selector(startTransfer) userInfo:nil repeats:NO];
	} else {
        [super fileCache:theFileCache didFailWithError:theError forURI:uri];
    }
}



@end
