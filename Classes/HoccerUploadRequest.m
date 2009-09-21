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
@synthesize data;
@synthesize type, filename;

- (id)initWithLocation: (CLLocation *)location gesture: (NSString *)gesture data: (NSData *)aData 
				   type: (NSString *)aType filename: (NSString *)aFilename delegate: (id)aDelegate
{
	self = [super init];
	if (self != nil) {
		self.delegate = aDelegate;
		
		self.data = aData;
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
	[data release];

	[super dealloc];
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
	NSLog(@"download uri %@", [aRequest.result valueForKey: @"upload_uri"]);

	request = [[PeerGroupPollingRequest alloc] initWithObject:aRequest.result 
																	 andDelegate:self];
	
	upload = [[UploadRequest alloc] initWithResult:aRequest.result data:self.data type: self.type 
										  filename: self.filename delegate: self];
	
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
	NSLog(@"error");
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
	if (uploadDidFinish && pollingDidFinish) {
		[self.delegate checkAndPerformSelector:@selector(requestDidFinishUpload:) withObject: self];
	}
}


@end
