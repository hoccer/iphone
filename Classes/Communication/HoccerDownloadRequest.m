//
//  HoccerDownloadRequest.m
//  Hoccer
//
//  Created by Robert Palmer on 16.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

#import "HoccerDownloadRequest.h"
#import "NSObject+DelegateHelper.h"

#import "PeerGroupRequest.h"
#import "PeerGroupPollingRequest.h"
#import "DownloadRequest.h"

#import "BaseHoccerRequest.h"



@implementation HoccerDownloadRequest

@synthesize delegate;


- (id)initWithLocation: (CLLocation *)location gesture: (NSString *)gesture delegate: (id) aDelegate
{
	self = [super init];
	if (self != nil) {
		self.delegate = aDelegate;
		request = [[PeerGroupRequest alloc] initWithLocation: location 
													 gesture: gesture 
													isSeeder: NO
													delegate: self];
	}
	
	return self;
}

- (void)cancel 
{
	[request cancel];
	[request release];
	
	request = nil;
}

- (void)dealloc
{
	[request release];
	[super dealloc];
}


#pragma mark -
#pragma mark Download Delegate Methods

- (void)finishedRequest: (PeerGroupRequest *)aRequest 
{
	NSLog(@"received peer uri: %@", [aRequest.result valueForKey:@"peer_uri"]);
	
	BaseHoccerRequest *pollingRequest = [[PeerGroupPollingRequest alloc] initWithObject: aRequest.result andDelegate: self];
	
	[request release];
	request = pollingRequest;
}


- (void)finishedPolling: (PeerGroupPollingRequest *)aRequest 
{
	[self checkAndPerformSelector: @selector(request:didPublishUpdate:)
					   withObject: self withObject: [aRequest.result valueForKey:@"message"]];
	
	BaseHoccerRequest *downloadRequest = [[DownloadRequest alloc] initWithObject:aRequest.result delegate:self];
	
	[request release];
	request = downloadRequest;
}


- (void)finishedDownload: (BaseHoccerRequest *)aRequest 
{
	[request release];
	request = nil;
	
	[self.delegate checkAndPerformSelector:@selector(requestDidFinishDownload:)
					withObject:aRequest];
}




#pragma mark -
#pragma mark BaseHoccerRequest Delegates

- (void)request:(BaseHoccerRequest *)aRequest didFailWithError: (NSError *)error 
{
	[request release];
	request = nil;
	
	[self.delegate checkAndPerformSelector: @selector(request:didFailWithError:) 
								withObject: self 
								withObject: error];
}

- (void)request: (BaseHoccerRequest *)aRequest didPublishUpdate: (NSString *)update 
{
	[self.delegate checkAndPerformSelector:@selector(request:didPublishUpdate:)
								withObject: self
								withObject: update];
}


- (void)request: (BaseHoccerRequest *)aRequest didPublishDownloadedPercentageUpdate: (NSNumber *)progress 
{
	[self.delegate checkAndPerformSelector:@selector(request:didPublishDownloadedPercentageUpdate:)
								withObject: self
								withObject: progress];
}


@end
