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
@synthesize cryptor;

- (void) fileCache:(HCFileCache *)fileCache didUpdateTransferProgress:(TransferProgress*)transferProgress {
    if (USES_DEBUG_MESSAGES) {  NSLog(@"fileCache didUpdateTransferProgress %@", transferProgress);}
    if (self.progress == nil || transferProgress.total >= self.progress.total) {
        self.progress = transferProgress;
    } else {
        NSLog(@"fileCache: didUpdateTransferProgress: total has become smaller, upload corrupted");
    }
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

- (NSInteger)transfersize {
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
