//
//  PeerGroupPollingRequest.m
//  Hoccer
//
//  Created by Robert Palmer on 07.09.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PeerGroupPollingRequest.h"
#import "NSObject+DelegateHelper.h"

#import "JSON.h"

@interface PeerGroupPollingRequest (private)
- (void)startRequest;
@end


@implementation PeerGroupPollingRequest

- (id)initWithObject: (id)aObject andDelegate: (id)aDelegate {
	self = [super init];
	if (self != nil) {
		self.delegate = aDelegate;
		
		NSURL *url = [NSURL URLWithString: [aObject valueForKey:@"peer_uri"]];
		
		[self.request setURL: url];
		[self startRequest];
		
		if ([aObject valueForKey:@"message"]) {
			[self.delegate checkAndPerformSelector: @selector(request:didPublishUpdate:)
										withObject: self withObject: [aObject valueForKey:@"message"]];
		}
	}
	
	return self;
}

- (void) dealloc
{
	[super dealloc];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection 
{
	int statusCode = [self.response statusCode];
	self.result = [self createJSONFromResult: receivedData];
	
	if (statusCode == 202) {
		[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(startRequest) userInfo:nil repeats:NO];
		return;
	}

	NSString *dataString = [[NSString alloc] initWithData: receivedData encoding: NSUTF8StringEncoding];
	[dataString release];
	self.connection = nil;
	
	if (statusCode >= 400) {
		NSError *error = [self createErrorFromResult: self.result];
		[self.delegate checkAndPerformSelector:@selector(request:didFailWithError:) withObject: self withObject: error];
	} else {
		[self.delegate checkAndPerformSelector:@selector(finishedPolling:) withObject: self];
	}
}

- (void)startRequest 
{
	if (canceled) {
		return;
	}
	
	self.connection = [[[NSURLConnection alloc] initWithRequest: self.request delegate:self] autorelease];
	if (!self.connection)  {
		NSLog(@"Error while executing url connection");
	}

	[receivedData setLength:0];
}

@end
