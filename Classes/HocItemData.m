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
#import "StatusViewController.h"
#import "Preview.h"

#import "HocLocation.h"

@implementation HocItemData

@synthesize content;
@synthesize contentView;
@synthesize viewOrigin;

@synthesize status;
@synthesize delegate;


- (void) dealloc {
	[content release];
	[contentView release];
	[request release];
	
	[super dealloc];
}

- (void)setContent:(HoccerContent *)newContent {
	if (content != newContent) {
		[content release];
		content = [newContent retain];
	}
	
	self.contentView = nil;
}

- (void)cancelRequest {
	if (request == nil) {
		return;
	}
	
	[request cancel];
	[request release];
	request = nil;

	if (isUpload) {
		if ([delegate respondsToSelector:@selector(hocItemUploadWasCanceled:)]) {
			[delegate hocItemUploadWasCanceled:self];
		}
	} else {
		if ([delegate respondsToSelector:@selector(hocItemDownloadWasCanceled:)]) {
			[delegate hocItemDownloadWasCanceled:self];
		}
	}
}

- (BOOL)hasActiveRequest {
	return request != nil;
}

- (Preview *)contentView {
	if (contentView == nil) {
		contentView = [[content desktopItemView] retain];
	}
	
	if (contentView == nil) {
		contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 150)];
		contentView.backgroundColor = [UIColor whiteColor];
	}
	
	return contentView;
}

- (void)uploadWithLocation: (HocLocation *)location gesture: (NSString *)gesture {
	if ([delegate respondsToSelector:@selector(hocItemWillStartUpload:)]) {
		[delegate hocItemWillStartUpload:self];
	}
	
	[content prepareSharing];
	request = [[HoccerUploadRequest alloc] initWithLocation:location gesture:gesture content: content 
													   type: [content mimeType] filename: [content filename] delegate:self];
	
	isUpload = YES;
}

- (void)downloadWithLocation:(HocLocation *)location gesture:(NSString *)gesture {
	if ([delegate respondsToSelector:@selector(hocItemWillStartDownload:)]) {
		[delegate hocItemWillStartDownload:self];
	}
	
	request = [[HoccerDownloadRequest alloc] initWithLocation: location gesture:gesture delegate: self];
	isUpload = NO;
}


#pragma mark -
#pragma mark Download Communication
- (void)requestDidFinishDownload: (BaseHoccerRequest *)aRequest {
	HoccerContent* hoccerContent = [[HoccerContentFactory sharedHoccerContentFactory] createContentFromResponse: aRequest.response 
																									   withData: aRequest.result];
	
	self.content = hoccerContent;	
	[request release];
	request = nil;
	
	if ([delegate respondsToSelector:@selector(hocItemWasReceived:)]) {
		[delegate hocItemWasReceived:self];
	}
	
}

#pragma mark -
#pragma mark Upload Communication 

- (void)requestDidFinishUpload: (BaseHoccerRequest *)aRequest {
	[request release];
	request = nil;
	
	if ([delegate respondsToSelector:@selector(hocItemWasSend:)]) {
		[delegate hocItemWasSend: self];
	}
}

#pragma mark -
#pragma mark BaseHoccerRequest Delegate Methods

- (void)request:(BaseHoccerRequest *)aRequest didFailWithError: (NSError *)error 
{
	self.status = [error localizedDescription];
	[request release];
	request = nil;
}

- (void)request: (BaseHoccerRequest *)aRequest didPublishUpdate: (NSString *)update 
{
	self.status = update;
}

- (void)request: (BaseHoccerRequest *)aRequest didPublishDownloadedPercentageUpdate: (NSNumber *)progress
{
}

@end
