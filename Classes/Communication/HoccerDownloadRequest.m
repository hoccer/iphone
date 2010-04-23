//
//  HoccerDownloadRequest.m
//  Hoccer
//
//  Created by Robert Palmer on 16.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "HoccerDownloadRequest.h"
#import "NSObject+DelegateHelper.h"

#import "PeerGroupRequest.h"
#import "DownloadRequest.h"

#import "BaseHoccerRequest.h"
#import "HocLocation.h"

@implementation HoccerDownloadRequest

@synthesize status;
@synthesize delegate;

- (id)initWithLocation:(HocLocation *)location gesture:(NSString *)gesture delegate:(id)aDelegate {
	self = [super init];
	if (self != nil) {
		self.delegate = aDelegate;
		request = [[PeerGroupRequest alloc] initWithLocation: location gesture: gesture delegate: self];
	}
	
	return self;
}

- (void)cancel {
	[request cancel];
	[request release];
	
	request = nil;
}

- (void)dealloc {
	[request release];
	[super dealloc];
}


#pragma mark -
#pragma mark Download Delegate Methods

- (void)peerGroupRequest:(PeerGroupRequest *)aRequest didReceiveUpdate:(NSDictionary *)update {
	self.status = update;
	
	NSArray *pieces = [self.status objectForKey:@"uploads"];
	if (downloadRequest == nil && [pieces count] > 0) {
		NSDictionary *piece = [pieces objectAtIndex:0];
		NSURL *downloadUrl = [NSURL URLWithString:[piece objectForKey:@"uri"]];
		downloadRequest = [[DownloadRequest alloc] initWithURL:downloadUrl delegate:self];
	}
}

- (void)downloadRequestDidFinish: (BaseHoccerRequest *)aRequest {
	[downloadRequest release];
	downloadRequest = nil;
	
	[self.delegate checkAndPerformSelector:@selector(hoccerConnectionDidFinishLoading:)
					withObject:self];
}

#pragma mark -
#pragma mark BaseHoccerRequest Delegates

- (void)request:(BaseHoccerRequest *)aRequest didFailWithError: (NSError *)error {
	[request release];
	request = nil;
	
	[self.delegate checkAndPerformSelector: @selector(hoccerConnection:didFailWithError:) 
								withObject: self 
								withObject: error];
}

- (void)request: (BaseHoccerRequest *)aRequest didPublishUpdate: (NSString *)update {
	[self.delegate checkAndPerformSelector:@selector(hoccerConnection:didPublishUpdate:)
								withObject: self
								withObject: update];
}


- (void)request: (BaseHoccerRequest *)aRequest didPublishDownloadedPercentageUpdate: (NSNumber *)progress {
	[self.delegate checkAndPerformSelector:@selector(hoccerConnection:didPublishDownloadedPercentageUpdate:)
								withObject: self
								withObject: progress];
}


@end
