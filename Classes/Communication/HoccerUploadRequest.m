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
#import "UploadRequest.h"


@interface HoccerUploadRequest ()

- (void) didFinishUpload;

@end

@implementation HoccerUploadRequest

@synthesize delegate;
@synthesize content;
@synthesize type, filename;
@synthesize status;

- (id)initWithLocation: (HocLocation *)location gesture: (NSString *)gesture content: (HoccerContent*)theContent 
				   type: (NSString *)aType filename: (NSString *)aFilename delegate: (id)aDelegate {
	self = [super init];
	if (self != nil) {
		isCanceled = NO;
		self.delegate = aDelegate;
		self.type = aType;
		self.content = theContent;
		self.filename = aFilename;
		
		request =[[PeerGroupRequest alloc] initWithLocation: location gesture: gesture delegate: self];
	}
	return self;
}

- (void)dealloc 
{
	[uploadUrl release];
	[type release];
	[filename release];
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

- (void)peerGroupRequest:(PeerGroupRequest *)aRequest didReceiveUpdate:(NSDictionary *)update {
	self.status = update;
	
	NSString *uploadUri = [self.status objectForKey:@"upload_uri"];
	if (!uploadDidFinish && upload == nil && timer == nil && uploadUri != nil) {
		timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(startUploadWhenDataIsReady:) 
											   userInfo: [NSDictionary dictionaryWithObject:uploadUri forKey:@"uploadUri"] repeats:YES];
		[timer retain];
	}
}

- (void)peerGroupRequestDidFinish: (PeerGroupRequest *)aRequest {
	[request release];
	request = nil;
	
	pollingDidFinish = YES;
	[self didFinishUpload];
}
									
									
- (void)uploadRequestDidFinished: (UploadRequest *)aRequest {
	[upload release];
	upload = nil;
	
	uploadDidFinish = YES;
	[self didFinishUpload];
}


#pragma mark -
#pragma mark BaseHoccerRequest Delegates

- (void)request:(BaseHoccerRequest *)aRequest didFailWithError: (NSError *)error {
	[self cancel];
	
	[request release];
	request = nil;
	[self.delegate checkAndPerformSelector: @selector(request:didFailWithError:) 
								withObject: self withObject: error];
}

- (void)request: (BaseHoccerRequest *)aRequest didPublishUpdate: (NSString *)update {
	[self.delegate checkAndPerformSelector:@selector(request:didPublishUpdate:)
								withObject: self withObject: update];
}

- (void)request: (BaseHoccerRequest *)aRequest didPublishDownloadedPercentageUpdate: (NSNumber *)progress {
	[self.delegate checkAndPerformSelector:@selector(request:didPublishDownloadedPercentageUpdate:)
								withObject: self withObject: progress];
}


#pragma mark -
#pragma mark Private Methods

- (void) didFinishUpload {
	if (uploadDidFinish && pollingDidFinish) {
		[self.delegate checkAndPerformSelector:@selector(requestDidFinishUpload:) withObject: self];
	}
}

- (void) startUploadWhenDataIsReady: (NSTimer *)theTimer {
	if (isCanceled) {
		[timer invalidate];
		[timer release];
		timer = nil;
		return;
	}
	
	if ([content isDataReady]) {
		NSURL *uploadURL = [NSURL URLWithString: [[timer userInfo] objectForKey:@"uploadUri"]];
		upload = [[UploadRequest alloc] initWithURL:uploadURL data:self.content.data type: self.type 
											  filename: self.filename delegate: self];
		[timer invalidate];
		[timer release];
		timer = nil;
	}
}


@end
