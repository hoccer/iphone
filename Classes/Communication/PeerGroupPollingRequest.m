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

@synthesize delegate;
@synthesize response;

- (id)initWithObject: (id)aObject andDelegate: (id)aDelegate {
	self = [super init];
	if (self != nil) {
		self.delegate = delegate;
		NSLog(@"verbinde mit %@", [aObject valueForKey:@"peer_uri"]);
		
		receivedData = [[NSMutableData alloc] init];

		NSURL *url = [NSURL URLWithString: [aObject valueForKey:@"peer_uri"]];
		request = [[NSMutableURLRequest requestWithURL:url] retain];

		[self startRequest];
	}
	
	return self;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)aResponse 
{
	self.response = aResponse;
	NSLog(@"status code: %d", [response statusCode]);
	NSLog(@"response length: %d", [response expectedContentLength]);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection 
{
	if ([response statusCode] == 202) {
		[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(startRequest) userInfo:nil repeats:NO];
		// [self startRequest];
		return;
	}
	
	NSLog(@"polling connection did finish");
	
	NSString *dataString = [[NSString alloc] initWithData: receivedData encoding: NSUTF8StringEncoding];
	NSLog(@"polling result: %@", dataString);
	
	[dataString release];
	[connection release];
	connection = nil;
	
	[delegate checkAndPerformSelector:@selector(finishedPolling:) withObject: self];
}

- (void)startRequest 
{
	[connection release];
	connection = [[[NSURLConnection alloc] initWithRequest:request delegate:self] retain];
	if (!connection)  {
		NSLog(@"Error while executing url connection");
	}
	
	[receivedData setLength:0];
}


- (void)dealloc {
	[super dealloc];
	[response release];	
	[connection release];
	
	[receivedData release];
}





@end
