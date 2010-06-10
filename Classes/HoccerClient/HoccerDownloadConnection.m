//
//  HoccerDownloadRequest.m
//  Hoccer
//
//  Created by Robert Palmer on 16.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "HoccerDownloadConnection.h"
#import "NSObject+DelegateHelper.h"

#import "PeerGroupRequest.h"
#import "DownloadRequest.h"

#import "BaseHoccerRequest.h"
#import "HocLocation.h"

@interface HoccerDownloadConnection ()

- (void)checkCompleteness;

@end




@implementation HoccerDownloadConnection

- (id)initWithLocation:(HocLocation *)aLocation gesture:(NSString *)aGesture delegate:(id)aDelegate {
	self = [super init];
	if (self != nil) {
		self.gesture = aGesture;
		self.delegate = aDelegate;
		self.location = aLocation;
		
		downloaded = NO;
	}
	
	return self;
}

- (void)startConnection {
	request = [[PeerGroupRequest alloc] initWithLocation:self.location gesture:self.gesture delegate:self];
}

- (void)cancel {
	[super cancel];
	canceled = YES;
	
	[request cancel];
	[request release];
	
	request = nil;
}

- (void)dealloc {
	[super dealloc];
}




- (void)peerGroupRequest:(PeerGroupRequest *)aRequest didReceiveUpdate:(NSDictionary *)update {
	if (canceled) {
		return;
	}

	self.status = update;
	
	if (eventURL == nil) {
		eventURL = [request.eventUri retain];
	}
	
	if ([delegate respondsToSelector:@selector(hoccerConnection:didUpdateStatus:)]) {
		[delegate hoccerConnection:self didUpdateStatus:self.status];
	}
	
	NSArray *pieces = [self.status objectForKey:@"uploads"];
	if (downloadRequest == nil && [pieces count] > 0 ) {
		NSDictionary *piece = [pieces objectAtIndex:0];
			NSURL *downloadUrl = [NSURL URLWithString:[piece objectForKey:@"uri"]];
			if (downloadUrl) {
				downloadRequest = [[DownloadRequest alloc] initWithURL:downloadUrl delegate:self];			
			}
	}
	
	[self checkCompleteness];
}



#pragma mark -
#pragma mark Download Delegate Methods
- (void)downloadRequestDidFinish: (BaseHoccerRequest *)aRequest {
	[downloadRequest release];
	downloadRequest = nil;
	downloaded = YES;
	
	self.responseBody = aRequest.result;
	self.responseHeader = aRequest.response;
	
	[self checkCompleteness];
}

#pragma mark -
#pragma mark BaseHoccerRequest Delegates

- (void)request: (BaseHoccerRequest *)aRequest didPublishUpdate: (NSString *)update {
	if (canceled) {
		return;
	}
	
	[self.delegate checkAndPerformSelector:@selector(hoccerConnection:didPublishUpdate:)
								withObject: self
								withObject: update];
}


- (void)request: (BaseHoccerRequest *)aRequest didPublishDownloadedPercentageUpdate: (NSNumber *)progress {
	if (canceled) {
		return;
	}
	
	[self.delegate checkAndPerformSelector:@selector(hoccerConnection:didUpdateTransfereProgress:)
								withObject: self
								withObject: progress];
}

#pragma mark -
#pragma mark Private Methods

- (void)checkCompleteness {
	if ([[self.status objectForKey:@"status_code"] intValue] == 200 && downloaded) {
		[request cancel];
		
		[self.delegate checkAndPerformSelector:@selector(hoccerConnectionDidFinishLoading:)
									withObject:self];
	}
	
}


@end
