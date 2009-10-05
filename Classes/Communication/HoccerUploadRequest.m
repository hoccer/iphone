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
#import "UploadRequest.h"


@interface HoccerUploadRequest (Private)

- (void) didFinishUpload;

@end



@implementation HoccerUploadRequest

@synthesize delegate;
@synthesize content;
@synthesize type, filename;

- (id)initWithLocation: (CLLocation *)location gesture: (NSString *)gesture content: (id <HoccerContent>)theContent 
				   type: (NSString *)aType filename: (NSString *)aFilename delegate: (id)aDelegate
{
	self = [super init];
	if (self != nil) {
		isCanceled = NO;
		self.delegate = aDelegate;
		
		self.content = theContent;
		self.type = aType;
		self.filename = aFilename;
		
		request =[[PeerGroupRequest alloc] initWithLocation: location 
													gesture: gesture 
												   isSeeder: YES
												   delegate: self];
		
		NSLog(@"uploading");
	}
	return self;
}

- (void)dealloc 
{
	[upload release];
	[content release];

	[super dealloc];
}


- (void)cancel 
{
	isCanceled = YES;
	
	[request cancel];
	[request release];
	request = nil;
	
	[upload cancel];
	[upload release];
	upload = nil;
}


#pragma mark -
#pragma mark Upload Delegate Methods

- (void)finishedRequest: (BaseHoccerRequest *) aRequest
{
	NSLog(@"download uri %@", [aRequest.result valueForKey: @"upload_uri"]);

	[request release];
	request = [[PeerGroupPollingRequest alloc] initWithObject:aRequest.result 
												  andDelegate:self];
	
	timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self
										   selector:@selector(startDownloadWhenDataIsReady:) 
										   userInfo: [NSDictionary dictionaryWithObject:aRequest forKey:@"request"]
											repeats:YES];
	
	
	
	
}

- (void)finishedPolling: (PeerGroupPollingRequest *)aRequest 
{
	[request release];
	request = nil;
	
	pollingDidFinish = YES;
	[self didFinishUpload];
}

- (void)finishedUpload: (UploadRequest *)aRequest
{
	[upload release];
	upload = nil;
	
	uploadDidFinish = YES;
	[self didFinishUpload];

}


#pragma mark -
#pragma mark BaseHoccerRequest Delegates

- (void)request:(BaseHoccerRequest *)aRequest didFailWithError: (NSError *)error 
{
	[self cancel];
	NSLog(@"error: %@", error);
	
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

#pragma mark -
#pragma mark Private Methods

- (void) didFinishUpload
{
	NSLog(@"upload did finish");
	if (uploadDidFinish && pollingDidFinish) {
		[self.delegate checkAndPerformSelector:@selector(requestDidFinishUpload:) withObject: self];
	}
}

- (void) startDownloadWhenDataIsReady: (NSTimer *)theTimer
{
	if (isCanceled) 
	{
		[timer invalidate];
		return;
	}
	
	if ([content isDataReady]) {
		BaseHoccerRequest *aRequest = [[theTimer userInfo] valueForKey:@"request"];
		
		[timer invalidate];
		
		upload = [[UploadRequest alloc] initWithResult:aRequest.result 
												  data:self.content.data type: self.type 
											  filename: self.filename delegate: self];
	}
}


@end
