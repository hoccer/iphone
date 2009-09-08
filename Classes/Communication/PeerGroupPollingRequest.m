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

@synthesize connection;

- (id)initWithObject: (id)aObject andDelegate: (id)aDelegate {
	self = [super init];
	if (self != nil) {
		self.delegate = aDelegate;
		NSLog(@"verbinde mit %@", [aObject valueForKey:@"peer_uri"]);
		
		NSURL *url = [NSURL URLWithString: [aObject valueForKey:@"peer_uri"]];
		request = [[NSMutableURLRequest requestWithURL:url] retain];

		[self startRequest];
	}
	
	return self;
}


- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection 
{
	if ([self.response statusCode] == 202) {
		[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(startRequest) userInfo:nil repeats:NO];
		return;
	}
	
	NSLog(@"polling connection did finish");
	
	NSString *dataString = [[NSString alloc] initWithData: receivedData encoding: NSUTF8StringEncoding];
	NSLog(@"polling result: %@", dataString);
	
	[dataString release];
	[connection release];
	connection = nil;

	self.result = [self createJSONFromResult: receivedData];
	[self.delegate checkAndPerformSelector:@selector(finishedPolling:) withObject: self];
}

- (void)startRequest 
{
	self.connection = [[[NSURLConnection alloc] initWithRequest:request delegate:self] retain];
	if (!self.connection)  {
		NSLog(@"Error while executing url connection");
	}
	
	[receivedData setLength:0];
}


- (void)dealloc {
	[super dealloc];
	[response release];	
	[connection release];
}





@end
