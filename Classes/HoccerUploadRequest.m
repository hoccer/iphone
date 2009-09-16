//
//  HoccerUploadContent.m
//  Hoccer
//
//  Created by Robert Palmer on 16.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "HoccerUploadRequest.h"

#import "NSObject+DelegateHelper.h"

#import "PeerGroupRequest.h"
#import "PeerGroupPollingRequest.h"


@implementation HoccerUploadRequest

@synthesize delegate;
@synthesize data;

- (id) initWithLocation: (CLLocation *)location gesture: (NSString *)gesture data: (NSData *)aData delegate: (id)aDelegate
{
	self = [super init];
	if (self != nil) {
		self.delegate = aDelegate;
		self.data = aData;
	
		request =[[PeerGroupRequest alloc] initWithLocation: location 
													gesture: gesture 
												   isSeeder: YES
												   delegate: self];
		
		NSLog(@"uploading");
	}
	return self;
}


- (void)cancel 
{
	[request cancel];
	[request release];
	
	request = nil;
}


#pragma mark -
#pragma mark Upload Delegate Methods

- (void)finishedRequest: (BaseHoccerRequest *) aRequest
{
	NSLog(@"download uri %@", [aRequest.result valueForKey: @"download_uri"]);

	request = [[PeerGroupPollingRequest alloc] initWithObject:aRequest.result 
																	 andDelegate:self];
}

- (void)finishedPolling: (PeerGroupPollingRequest *)aRequest 
{
	[request release];
	request = nil;
	
	[self.delegate checkAndPerformSelector:@selector(requestDidFinishUpload:) withObject: aRequest];
}



#pragma mark -
#pragma mark BaseHoccerRequest Delegates

- (void)request:(BaseHoccerRequest *)aRequest didFailWithError: (NSError *)error 
{
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


@end
