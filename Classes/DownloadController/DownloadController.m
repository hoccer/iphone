//
//  DownloadController.m
//  Hoccer
//
//  Created by Robert Palmer on 08.12.10.
//  Copyright 2010 Hoccer GmbH. All rights reserved.
//

#import "DownloadController.h"

#define CONCURENT_TRANSFERES 1

@interface DownloadController ()

- (void)startDownload;
- (void)monitorContent: (NSObject <Downloadable> *)theContent;

@end



@implementation DownloadController

- (id)init {
	self = [super init];
	if (self != nil) {
		downloadQueue = [[NSMutableArray alloc] init];
		activeDownloads = [[NSMutableArray alloc] init];
	}
	
	return self;
}

- (void) dealloc {
	[downloadQueue release];
	[activeDownloads release];
	
	[super dealloc];
}

- (void)addContentToDownloadQueue:(id <Downloadable>)downloadable {
	[downloadQueue addObject:downloadable];
	[self startDownload];
}

- (void)cancelDownloads {
	
}

- (void)startDownload {
	if ([activeDownloads count] < CONCURENT_TRANSFERES && [downloadQueue count] > 0) {
		NSObject <Downloadable> *nextObject = [downloadQueue objectAtIndex:0];
		
		[nextObject startTransfer];
		[self monitorContent:nextObject];
		[activeDownloads addObject:nextObject];
		
		[downloadQueue removeObjectAtIndex:0];
	}
}

- (void)monitorContent: (NSObject <Downloadable> *)theContent {
	[theContent addObserver:self forKeyPath:@"error" options:NSKeyValueObservingOptionNew context:nil];
	[theContent addObserver:self forKeyPath:@"progress" options:NSKeyValueObservingOptionNew context:nil];
	[theContent addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	NSLog(@"updated %@", change);
	
//	if ([keyPath isEqual:@"error"]) {
//		[self setError: [change objectForKey:NSKeyValueChangeNewKey]];
//	}
//	
//	if ([keyPath isEqual:@"progress"]) {
//		[self setProgressUpdate: [[change objectForKey:NSKeyValueChangeNewKey] floatValue]];
//	}
}

- (void)error: (id)object {
	NSLog(@"error: %@");
	
	[activeDownloads removeObject:object];
	[self startDownload];
}

@end
