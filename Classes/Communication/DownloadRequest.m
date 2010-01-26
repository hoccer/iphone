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

- (id)initWithObject: (id)aObject delegate: (id)aDelegate
{
	self = [super init];
	if (self != nil) {
		self.delegate = aDelegate;
				
		NSURL *url = [NSURL URLWithString: [[aObject valueForKey:@"resources"] objectAtIndex:0]];

		[self.request setURL: url];
		[self startRequest];
		
		isDownloading = NO;
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
	
	if (statusCode == 202) {
		[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(startRequest) userInfo:nil repeats:NO];
		return;
	}
			
	NSLog(@"download connection did finish");
			
	self.result = receivedData;	
	self.connection = nil;
	
	if (statusCode >= 400) {
		[self.delegate checkAndPerformSelector:@selector(request:didFailWithError:) withObject: self withObject: nil];
	} else {
		[self.delegate checkAndPerformSelector:@selector(finishedDownload:) withObject: self];
	}
	
	isDownloading = NO;
}
		
- (void)startRequest 
{
	if (canceled) {
		return;
	}
	
	self.connection = [NSURLConnection connectionWithRequest: self.request delegate:self];
	if (!self.connection)  {
		NSLog(@"Error while executing url connection");
	}
			
	[receivedData setLength:0];
	downloaded = 0;
}


- (void)connection:(NSURLConnection *)aConnection didReceiveData:(NSData *)data {
	[super connection: connection didReceiveData:data];
	
	if (isDownloading) {
		downloaded += [data length]; 

		float percentage =  (float)downloaded / (float)[self.response expectedContentLength];
		
		[self.delegate checkAndPerformSelector: @selector(request:didPublishDownloadedPercentageUpdate:)
			withObject: self withObject: [NSNumber numberWithFloat:  percentage]];
		
	}
}

- (void)connection:(NSURLConnection *)aConnection didReceiveResponse:(NSHTTPURLResponse *)aResponse 
{
	[super connection: aConnection didReceiveResponse: aResponse];
	
	if ([aResponse statusCode] == 200) {
		isDownloading = YES;
		
		[delegate checkAndPerformSelector:@selector(readyForStartingDownload:) withObject:self];
	}
}

		

@end
