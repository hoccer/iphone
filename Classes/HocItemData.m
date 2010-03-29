//
//  HocItemData.m
//  Hoccer
//
//  Created by Robert Palmer on 29.03.10.
//  Copyright 2010 Art+Com AG. All rights reserved.
//

#import "HocItemData.h"
#import "HoccerRequest.h"
#import "BaseHoccerRequest.h"
#import "HoccerContent.h"
#import "HoccerContentFactory.h"

#import "DragAndDropViewController.h"

@implementation HocItemData

@synthesize dragAndDropViewConroller;

- (id) init
{
	self = [super init];
	if (self != nil) {
		
	}
	return self;
}




- (void) dealloc
{
	[dragAndDropViewConroller release];
	[request release];
	
	[super dealloc];
}


#pragma mark -
#pragma mark Download Communication Delegate Methods
- (void)requestIsReadyToStartDownload: (BaseHoccerRequest *)aRequest
{
	//	if ([HoccerContentFactory isSupportedType: [aRequest.response MIMEType]])
	//		return;
	//	
	//	[aRequest cancel];
	//	
	//	NSURL *url = [aRequest.request URL];
	//	self.hoccerContent = [[HoccerUrl alloc] initWithData: [[url absoluteString] dataUsingEncoding: NSUTF8StringEncoding]];
	//	
	//	receivedContentView = [[ReceivedContentView alloc] initWithNibName:@"ReceivedContentView" bundle:nil];
	//	
	//	receivedContentView.delegate = self;
	//	[receivedContentView setHoccerContent: self.hoccerContent];
	//	
	//	[viewController presentModalViewController: receivedContentView animated:YES];
	//	
	//	[request release];
	//	request = nil;
	//	
	//	[statusViewController hideActivityInfo];
}

- (void)requestDidFinishDownload: (BaseHoccerRequest *)aRequest
{
	id <HoccerContent> hoccerContent = [[HoccerContentFactory sharedHoccerContentFactory] createContentFromResponse: aRequest.response 
																										   withData: aRequest.result];
	dragAndDropViewConroller.content = hoccerContent;	
	[request release];
	request = nil;
}

#pragma mark -
#pragma mark Upload Communication 

- (void)requestDidFinishUpload: (BaseHoccerRequest *)aRequest
{
	[request release];
	request = nil;
}

#pragma mark -
#pragma mark BaseHoccerRequest Delegate Methods

- (void)request:(BaseHoccerRequest *)aRequest didFailWithError: (NSError *)error 
{
	// [statusViewController setError: [error localizedDescription]];
	[dragAndDropViewConroller resetViewAnimated:YES];
	[request release];
	request = nil;
	
	// [statusViewController hideActivityInfo];
}

- (void)request: (BaseHoccerRequest *)aRequest didPublishUpdate: (NSString *)update 
{
	// [statusViewController setUpdate: update];
}

- (void)request: (BaseHoccerRequest *)aRequest didPublishDownloadedPercentageUpdate: (NSNumber *)progress
{
	// [statusViewController setProgressUpdate:[progress floatValue]];
}

- (void)cancelRequest {
	[request cancel];
	[request release];
	
	request = nil;
}

- (BOOL)hasActiveRequest {
	return request != nil;
}




@end
