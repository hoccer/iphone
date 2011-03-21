//
//  DownloadController.m
//  Hoccer
//
//  Created by Robert Palmer on 08.12.10.
//  Copyright 2010 Hoccer GmbH. All rights reserved.
//

#import "TransferController.h"

#define CONCURENT_TRANSFERES 3

@interface TransferController ()

- (void)startDownload;
- (void)monitorContent: (NSObject <Transferable> *)theContent;
- (void)removeObservers: (NSObject <Transferable> *)theContent;

- (void)error: (NSError *)error forTransfer: (id)object;
- (void)progress: (NSNumber *)progress forTransfer: (id)object;
- (void)state: (TransferableState) state forTransfer: (id)object;

@end

@implementation TransferController
@synthesize delegate;

- (id)init {
	self = [super init];
	if (self != nil) {
		downloadQueue = [[NSMutableArray alloc] init];
		activeDownloads = [[NSMutableArray alloc] init];
	}
	
	return self;
}

- (void)addContentToTransferQueue:(id <Transferable>)downloadable {
	[downloadQueue addObject:downloadable];
	[self startDownload];
}

- (void)cancelDownloads {
	for (id <Transferable> download in activeDownloads) {
		[self removeObservers:download];
		[download cancelTransfer];
	}
	
	[activeDownloads removeAllObjects];
	[downloadQueue removeAllObjects];
}

- (BOOL)hasTransfers {	
	return ([activeDownloads count] > 0 || [downloadQueue count] > 0);
}

- (void)startDownload {
	if ([activeDownloads count] < CONCURENT_TRANSFERES && [downloadQueue count] > 0) {
		NSObject <Transferable> *nextObject = [downloadQueue objectAtIndex:0];
		
		[nextObject startTransfer];
		[self monitorContent:nextObject];
		[activeDownloads addObject:nextObject];
		
		[downloadQueue removeObjectAtIndex:0];
    }
}

- (void)finalizeDownload: (NSObject <Transferable> *)object {
	[self removeObservers:object];
	[activeDownloads removeObject:object];

	[self startDownload];
}

- (void)monitorContent: (NSObject <Transferable> *)theContent {
	[theContent addObserver:self forKeyPath:@"error" options:NSKeyValueObservingOptionNew context:nil];
	[theContent addObserver:self forKeyPath:@"progress" options:NSKeyValueObservingOptionNew context:nil];
	[theContent addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeObservers: (NSObject <Transferable> *)theContent {
	[theContent removeObserver:self forKeyPath:@"error"];
	[theContent removeObserver:self forKeyPath:@"progress"];
	[theContent removeObserver:self forKeyPath:@"state"];
}

#pragma mark -
#pragma mark Dispatch Changes

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqual:@"error"]) {
		[self error: [change objectForKey:NSKeyValueChangeNewKey] forTransfer: object];
	}
	
	if ([keyPath isEqual:@"progress"]) {
		[self progress: [change objectForKey:NSKeyValueChangeNewKey] forTransfer: object];
	}
	
	if ([keyPath isEqual:@"state"]) {
		[self state: [[change objectForKey:NSKeyValueChangeNewKey] intValue] forTransfer: object];
	}
}


- (void)error: (NSError *)error forTransfer: (id)object {
	[object retain];
	
	[self finalizeDownload:object];
	
	if ([delegate respondsToSelector:@selector(transferController:didFailWithError:forTransfer:)]) {
		[delegate transferController:self didFailWithError:error forTransfer:object];
	}
	
	[object release];
}

- (void)progress: (NSNumber *)progress forTransfer: (id)object {	
	if ([delegate respondsToSelector:@selector(transferController:didUpdateProgress:forTransfer:)]) {
		[delegate transferController:self didUpdateProgress:progress forTransfer:object];
	}
}

- (void)state: (TransferableState) state forTransfer: (id)object {
	[object retain];
	switch (state) {
		case TransferableStateTransferred:
			[self finalizeDownload:object];
			if ([delegate respondsToSelector:@selector(transferController:didFinishTransfer:)]) {
				[delegate transferController:self didFinishTransfer:object];
			}
			
			break;
		case TransferableStateReady:
			if ([delegate respondsToSelector:@selector(transferController:didPrepareContent:)]) {
				[delegate transferController:self didPrepareContent:object];
			}
			break;

		default:
			break;
	}
	[object release];
}

- (void) dealloc {
	[downloadQueue release];
	[activeDownloads release];
	
	[super dealloc];
}


@end
