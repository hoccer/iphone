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
#import "HoccerUploadRequest.h"
#import "HoccerDownloadRequest.h"
#import "HoccerContent.h"
#import "HoccerContentFactory.h"

#import "HocLocation.h"

@implementation HocItemData

@synthesize content;
@synthesize contentView;
@synthesize viewOrigin;

- (id) init {
	self = [super init];
	if (self != nil) {
		
	}
	return self;
}

- (void) dealloc {
	[content release];
	[contentView release];
	
	[request release];
	
	[super dealloc];
}


- (void)requestDidFinishDownload: (BaseHoccerRequest *)aRequest
{
	HoccerContent* hoccerContent = [[HoccerContentFactory sharedHoccerContentFactory] createContentFromResponse: aRequest.response 
																										   withData: aRequest.result];
	
	self.content = hoccerContent;	
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
	// [contentView resetViewAnimated:YES];
	[request release];
	request = nil;

	// [statusViewController setError: [error localizedDescription]];
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

- (void)uploadWithLocation: (HocLocation *)location gesture: (NSString *)gesture {
	[content prepareSharing];
	request = [[HoccerUploadRequest alloc] initWithLocation:location gesture:gesture content: content 
													   type: [content mimeType] filename: [content filename] delegate:self];
}

- (void)downloadWithLocation:(HocLocation *)location gesture:(NSString *)gesture {
	request = [[HoccerDownloadRequest alloc] initWithLocation: location gesture:gesture delegate: self];
}

- (Preview *)contentView {
	return [content desktopItemView];
}

@end
