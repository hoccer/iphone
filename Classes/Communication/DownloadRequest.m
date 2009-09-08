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
- (void)startRequest;
@end


@implementation DownloadRequest

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
	int statusCode = [self.response statusCode];
	
	if (statusCode == 202) {
		[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(startRequest) userInfo:nil repeats:NO];
		return;
	}
			
	NSLog(@"download connection did finish");
			
	NSString *dataString = [[NSString alloc] initWithData: receivedData encoding: NSUTF8StringEncoding];
	NSLog(@"download result: %@", dataString);
			
	[dataString release];
	[connection release];
	connection = nil;
	
	if (statusCode >= 400) {
		[self.delegate checkAndPerformSelector:@selector(request:didFailWithError:) withObject: self withObject: nil];
	} else {
		[self.delegate checkAndPerformSelector:@selector(finishedDownload:) withObject: self];
	}
}
		

- (void)startRequest 
{
	self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
	if (!self.connection)  {
		NSLog(@"Error while executing url connection");
	}
			
	[receivedData setLength:0];
}
		

@end
