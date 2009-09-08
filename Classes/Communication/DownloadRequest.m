//
//  DownloadRequest.m
//  Hoccer
//
//  Created by Robert Palmer on 08.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import "DownloadRequest.h"
#import "NSObject+DelegateHelper.h"

@interface DownloadRequest (private)
- (void)sstartRequest;
@end


@implementation DownloadRequest

@synthesize connection;
@synthesize request;

- (id)initWithObject: (id)aObject delegate: (id)aDelegate
{
	self = [super init];
	if (self != nil) {
		self.delegate = aDelegate;
		
		NSLog(@"verbinde mit %@", [[aObject valueForKey:@"resources"] objectAtIndex:0]);
		
		NSURL *url = [NSURL URLWithString: [[aObject valueForKey:@"resources"] objectAtIndex:0]];
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
			
	[delegate checkAndPerformSelector:@selector(finishedPolling:) withObject: self];
}
		

- (void)startRequest 
{
	self.connection = [[[NSURLConnection alloc] initWithRequest:request delegate:self] retain];
	if (!self.connection)  {
		NSLog(@"Error while executing url connection");
	}
			
	[receivedData setLength:0];
}
		

@end
