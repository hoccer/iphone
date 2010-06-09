//
//  HoccerUploadContent.m
//  Hoccer
//
//  Created by Robert Palmer on 16.09.09.
//  Copyright 2009 ART+COM. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "HoccerUploadConnection.h"

#import "NSObject+DelegateHelper.h"

#import "PeerGroupRequest.h"
#import "UploadRequest.h"
#import "DownloadRequest.h"


@interface HoccerUploadConnection ()

- (void) checkCompleteness;

@end

@implementation HoccerUploadConnection

@synthesize content;
@synthesize type, filename;

- (id)initWithLocation: (HocLocation *)aLocation gesture: (NSString *)aGesture content: (HoccerContent*)theContent 
				   type: (NSString *)aType filename: (NSString *)aFilename delegate: (id)aDelegate {
	self = [super init];
	if (self != nil) {
		self.gesture = aGesture;
		self.location = aLocation;
		self.delegate = aDelegate;
		self.type = aType;
		self.content = theContent;
		self.filename = aFilename;
		
		canceled = NO;
	}
	return self;
}

- (void)startConnection {
	request =[[PeerGroupRequest alloc] initWithLocation: self.location gesture: self.gesture delegate: self];
}

- (void)dealloc {
	NSLog(@"upload: %@ - request: %@", upload, request);
	[request cancel];
	[uploadUrl release];
	[type release];
	[filename release];
	[upload release];
	[content release];

	[super dealloc];
}


- (void)cancel {
	[super cancel];
	canceled = YES;

	[upload cancel];
	[upload release];
	upload = nil;
	
	[request cancel];
	[request release];
	request = nil;
}


#pragma mark -
#pragma mark Upload Delegate Methods

- (void)peerGroupRequest:(PeerGroupRequest *)aRequest didReceiveUpdate:(NSDictionary *)update {
	NSLog(@"didReceiveUpdate");
	if (canceled) {
		return;
	}
	
	self.status = update;
	
	if ([delegate respondsToSelector:@selector(hoccerConnection:didUpdateStatus:)]) {
		[delegate hoccerConnection:self didUpdateStatus:self.status];
	}
	
	if (eventURL == nil) {
		eventURL = [request.eventUri retain];
	}
	
	NSString *uploadUri = [self.status objectForKey:@"upload_uri"];
	if (!uploadDidFinish && upload == nil && timer == nil && uploadUri != nil) {
		timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(startUploadWhenDataIsReady:) 
											   userInfo: [NSDictionary dictionaryWithObject:uploadUri forKey:@"uploadUri"] repeats:YES];
		[timer retain];
	}
	
	if (uploadDidFinish && [[status objectForKey:@"status_code"] intValue] == 200) {
		[request cancel];
		pollingDidFinish = YES;
		
		[self checkCompleteness];
	}
}

- (void)uploadRequestDidFinished: (UploadRequest *)aRequest {
	[upload release];
	upload = nil;
	
	uploadDidFinish = YES;
	[self checkCompleteness];
}


#pragma mark -
#pragma mark BaseHoccerRequest Delegates

- (void)request: (DownloadRequest *)aRequest didPublishDownloadedPercentageUpdate: (NSNumber *)progress {
	[self.delegate checkAndPerformSelector:@selector(hoccerConnection:didUpdateTransfereProgress:)
								withObject: self withObject: progress];
}


#pragma mark -
#pragma mark Private Methods

- (void) checkCompleteness {
	if (canceled) {
		return;
	}
	
	if (uploadDidFinish && pollingDidFinish) {
		NSLog(@"request complete");
		[self.delegate checkAndPerformSelector:@selector(hoccerConnectionDidFinishLoading:) withObject: self];
	}
}

- (void) startUploadWhenDataIsReady: (NSTimer *)theTimer {
	if (canceled) {
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
